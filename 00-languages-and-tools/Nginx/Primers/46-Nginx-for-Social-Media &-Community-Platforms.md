# Primer 46: Nginx for Social Media & Community Platforms

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for social media and community platforms. Understanding these concepts is essential for building scalable, real-time, and engaging social applications.

## P46.1 Social Media Architecture

### Social Platform Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SOCIAL MEDIA ARCHITECTURE                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX SOCIAL GATEWAY                           │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    CONTENT FEED                           │ │      │
│  │  │  • Timelines        • News Feed        • Recommendations │ │      │
│  │  │  • Trending         • Personalization   • Search          │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    SOCIAL INTERACTIONS                    │ │      │
│  │  │  • Posts           • Comments          • Likes           │ │      │
│  │  │  • Shares          • Reactions         • Mentions        │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    REAL-TIME COMMUNICATION                │ │      │
│  │  │  • Messaging        • Notifications     • Live Updates    │ │      │
│  │  │  • Presence         • Video/Audio       • Stories         │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    SOCIAL SERVICES                               │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ Feed       │  │ Social     │  │ Messaging  │  │ User     │ │      │
│  │  │ Service    │  │ Service    │  │ Service    │  │ Service  │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Social Platform Configuration

```nginx
# nginx-social.conf - Complete Social Platform
# ============================================================================
# NGINX SOCIAL MEDIA & COMMUNITY PLATFORM
# Complete production-ready social platform configuration
# ============================================================================

http {
    # =========================================================================
    # SOCIAL PLATFORM SETTINGS
    # =========================================================================
    # Large payloads for media and posts
    client_max_body_size 50M;
    client_body_buffer_size 1M;
    
    # Buffer settings
    client_header_buffer_size 4k;
    large_client_header_buffers 8 8k;
    
    # Timeouts for real-time
    client_body_timeout 60s;
    client_header_timeout 60s;
    send_timeout 60s;
    keepalive_timeout 300s;
    keepalive_requests 10000;
    
    # =========================================================================
    # SOCIAL PLATFORM CACHING
    # =========================================================================
    # Feed cache
    proxy_cache_path /var/cache/nginx/feed_cache
        levels=1:2
        keys_zone=feed_cache:1g
        max_size=20g
        inactive=1h
        use_temp_path=off;
    
    # Media cache
    proxy_cache_path /var/cache/nginx/media_cache
        levels=1:2
        keys_zone=media_cache:500m
        max_size=10g
        inactive=30d
        use_temp_path=off;
    
    # =========================================================================
    # SOCIAL PLATFORM UPSTREAMS
    # =========================================================================
    # Feed Service
    upstream feed_service {
        least_conn;
        server feed1:8001 max_fails=3 fail_timeout=30s;
        server feed2:8001 max_fails=3 fail_timeout=30s;
        server feed3:8001 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Social Interaction Service
    upstream social_service {
        least_conn;
        server social1:8002 max_fails=3 fail_timeout=30s;
        server social2:8002 max_fails=3 fail_timeout=30s;
        server social3:8002 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Messaging Service
    upstream messaging_service {
        least_conn;
        server msg1:8003 max_fails=3 fail_timeout=30s;
        server msg2:8003 max_fails=3 fail_timeout=30s;
        server msg3:8003 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # User Service
    upstream user_service {
        server users1:8004 max_fails=3 fail_timeout=30s;
        server users2:8004 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Notification Service
    upstream notification_service {
        server notify1:8005 max_fails=3 fail_timeout=30s;
        server notify2:8005 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Search Service
    upstream search_service {
        server search1:8006 max_fails=3 fail_timeout=30s;
        server search2:8006 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # RATE LIMITING
    # =========================================================================
    limit_req_zone $binary_remote_addr zone=feed:10m rate=60r/m;
    limit_req_zone $binary_remote_addr zone=social:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=messaging:10m rate=200r/m;
    limit_req_zone $binary_remote_addr zone=search:10m rate=30r/m;
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
    
    # =========================================================================
    # SOCIAL PLATFORM SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name social.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/social.crt;
        ssl_certificate_key /etc/nginx/ssl/social.key;
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
        
        # Social platform headers
        add_header X-Social-Gateway "nginx" always;
        add_header X-Social-Version "2.0.0" always;
        
        # Global Rate Limiting
        limit_req zone=feed burst=20 nodelay;
        limit_conn conn_limit 10;
        
        # =========================================================================
        # NEWS FEED
        # =========================================================================
        location /feed/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=feed burst=10 nodelay;
            
            # Feed caching
            proxy_cache feed_cache;
            proxy_cache_key $scheme$host$request_uri$auth_user_id;
            proxy_cache_valid 200 30s;
            proxy_cache_use_stale error timeout updating;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://feed_service/feed/;
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
        # CREATE POST
        # =========================================================================
        location /posts/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=social burst=10 nodelay;
            
            # No caching for posts
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            proxy_pass http://social_service/posts/;
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
        # SOCIAL INTERACTIONS (LIKES, COMMENTS)
        # =========================================================================
        location /interactions/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=social burst=20 nodelay;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            proxy_pass http://social_service/interactions/;
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
        # REAL-TIME MESSAGING (WEBSOCKET)
        # =========================================================================
        location /messages/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=messaging burst=20 nodelay;
            limit_conn conn_limit 5;
            
            # WebSocket upgrade
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Recipient-ID $http_x_recipient_id;
            
            proxy_buffering off;
            proxy_cache off;
            
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
            
            proxy_pass http://messaging_service/messages/;
        }
        
        # =========================================================================
        # NOTIFICATIONS (SSE)
        # =========================================================================
        location /notifications/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=messaging burst=10 nodelay;
            
            # SSE headers
            add_header Content-Type "text/event-stream";
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            add_header X-Accel-Buffering "no";
            
            proxy_buffering off;
            proxy_cache off;
            
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
            
            proxy_pass http://notification_service/notifications/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
        }
        
        # =========================================================================
        # USER PROFILES
        # =========================================================================
        location /users/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=feed burst=10 nodelay;
            
            # Cache user profiles
            proxy_cache feed_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 5m;
            add_header X-Cache-Status $upstream_cache_status;
            
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
        # SEARCH
        # =========================================================================
        location /search/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=search burst=10 nodelay;
            
            # Cache search results
            proxy_cache feed_cache;
            proxy_cache_key $scheme$host$request_uri$auth_user_id;
            proxy_cache_valid 200 30s;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://search_service/search/;
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
        # PRESENCE STATUS
        # =========================================================================
        location /presence/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=messaging burst=20 nodelay;
            
            # WebSocket upgrade
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            
            proxy_buffering off;
            proxy_cache off;
            
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
            
            proxy_pass http://social_service/presence/;
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
        # SOCIAL PLATFORM STATUS
        # =========================================================================
        location /social/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "service_status":{
                    "feed":$(curl -s -o /dev/null -w "%{http_code}" http://feed1:8001/health),
                    "social":$(curl -s -o /dev/null -w "%{http_code}" http://social1:8002/health),
                    "messaging":$(curl -s -o /dev/null -w "%{http_code}" http://msg1:8003/health),
                    "users":$(curl -s -o /dev/null -w "%{http_code}" http://users1:8004/health),
                    "notifications":$(curl -s -o /dev/null -w "%{http_code}" http://notify1:8005/health),
                    "search":$(curl -s -o /dev/null -w "%{http_code}" http://search1:8006/health)
                },
                "active_users":$(tail -10000 /var/log/nginx/access.log | grep -o '"X-User-ID":"[^"]*"' | cut -d'"' -f4 | sort -u | wc -l),
                "active_connections":$(netstat -an | grep ':443' | grep ESTABLISHED | wc -l),
                "cache_hit_rate":$(( $(tail -1000 /var/log/nginx/access.log | grep -c '"X-Cache-Status":"HIT"') * 100 / $(tail -1000 /var/log/nginx/access.log | wc -l) )),
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

## P46.2 Social Features

### Trending & Personalization

```nginx
# nginx-social-trending.conf - Trending & Personalization
# ============================================================================
# NGINX SOCIAL TRENDING & PERSONALIZATION
# Real-time trending and personalized content
# ============================================================================

http {
    # =========================================================================
    # TRENDING UPSTREAMS
    # =========================================================================
    upstream trending_service {
        least_conn;
        server trending1:8007 max_fails=3 fail_timeout=30s;
        server trending2:8007 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # PERSONALIZATION UPSTREAMS
    # =========================================================================
    upstream personalization_service {
        server personalize1:8008 max_fails=3 fail_timeout=30s;
        server personalize2:8008 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # TRENDING & PERSONALIZATION ENDPOINTS
    # =========================================================================
    server {
        listen 443 ssl http2;
        server_name social.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/social.crt;
        ssl_certificate_key /etc/nginx/ssl/social.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        
        # =========================================================================
        # TRENDING
        # =========================================================================
        location /trending/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=feed burst=10 nodelay;
            
            # Cache trending
            proxy_cache feed_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 30s;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://trending_service/trending/;
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
        # PERSONALIZED FEED
        # =========================================================================
        location /personalized/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=feed burst=10 nodelay;
            
            # Cache personalized feed
            proxy_cache feed_cache;
            proxy_cache_key $scheme$host$request_uri$auth_user_id;
            proxy_cache_valid 200 30s;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://personalization_service/personalized/;
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
    }
}
```

## P46.3 Social Platform Monitoring

### Social Platform Dashboard

```bash
#!/bin/bash
# social-monitor.sh - Social platform monitoring

echo "=== Social Platform Monitoring Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get engagement stats
get_engagement_stats() {
    local posts=$(tail -10000 /var/log/nginx/access.log | grep -c "/posts/")
    local interactions=$(tail -10000 /var/log/nginx/access.log | grep -c "/interactions/")
    local messages=$(tail -10000 /var/log/nginx/access.log | grep -c "/messages/")
    echo "  Engagement Statistics:"
    echo "    Posts Created: $posts"
    echo "    Interactions: $interactions"
    echo "    Messages Sent: $messages"
}

# Function: Get user stats
get_user_stats() {
    local users=$(tail -10000 /var/log/nginx/access.log | grep -o '"X-User-ID":"[^"]*"' | cut -d'"' -f4 | sort -u | wc -l)
    local active=$(tail -1000 /var/log/nginx/access.log | grep -o '"X-User-ID":"[^"]*"' | cut -d'"' -f4 | sort -u | wc -l)
    echo "  User Statistics:"
    echo "    Total Users: $users"
    echo "    Active Users (last 1000 req): $active"
}

# Function: Get real-time stats
get_realtime_stats() {
    local ws_conns=$(netstat -an | grep ':443' | grep ESTABLISHED | grep -c "Upgrade")
    local sse_conns=$(netstat -an | grep ':443' | grep ESTABLISHED | grep -c "event-stream")
    echo "  Real-Time Statistics:"
    echo "    WebSocket Connections: $ws_conns"
    echo "    SSE Connections: $sse_conns"
}

# Function: Get trending stats
get_trending_stats() {
    local trending_hits=$(tail -10000 /var/log/nginx/access.log | grep -c "/trending/")
    local personalized_hits=$(tail -10000 /var/log/nginx/access.log | grep -c "/personalized/")
    echo "  Content Delivery:"
    echo "    Trending Views: $trending_hits"
    echo "    Personalized Views: $personalized_hits"
}

# Main display
while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              SOCIAL PLATFORM MONITORING DASHBOARD             ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 ENGAGEMENT STATISTICS:"
    get_engagement_stats
    echo ""
    get_user_stats
    echo ""
    get_realtime_stats
    echo ""
    get_trending_stats
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx for social media and community platforms. Use these techniques to build scalable, real-time, and engaging social applications.
