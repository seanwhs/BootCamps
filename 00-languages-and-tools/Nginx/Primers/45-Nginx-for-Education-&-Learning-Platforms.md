# Primer 45: Nginx for Education & Learning Platforms

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for education and learning platforms. Understanding these concepts is essential for building scalable, interactive, and secure educational technology solutions.

## P45.1 Education Platform Architecture

### EdTech Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    EDUCATION PLATFORM ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX ED-TECH GATEWAY                          │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    LEARNING MANAGEMENT                    │ │      │
│  │  │  • Courses           • Lessons         • Assessments      │ │      │
│  │  │  • Progress Tracking  • Certificates    • Badges          │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    INTERACTIVE LEARNING                   │ │      │
│  │  │  • Video Streaming  • Real-time Quizzes  • Collaboration │ │      │
│  │  │  • Virtual Labs      • Whiteboards       • Discussion    │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    ANALYTICS & PERSONALIZATION            │ │      │
│  │  │  • Student Analytics  • Adaptive Learning  • Recommendations│ │      │
│  │  │  • Performance Tracking • Engagement Metrics  • Reporting  │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    EDUCATION SERVICES                            │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ Course     │  │ Assessment │  │ Video      │  │ Student  │ │      │
│  │  │ Service    │  │ Service    │  │ Service    │  │ Service  │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Education Platform Configuration

```nginx
# nginx-education.conf - Complete Education Platform
# ============================================================================
# NGINX EDUCATION & LEARNING PLATFORM
# Complete production-ready education platform configuration
# ============================================================================

http {
    # =========================================================================
    # EDUCATION PLATFORM SETTINGS
    # =========================================================================
    # Large payloads for video and assessments
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
    # EDUCATION PLATFORM CACHING
    # =========================================================================
    # Course cache
    proxy_cache_path /var/cache/nginx/course_cache
        levels=1:2
        keys_zone=course_cache:500m
        max_size=10g
        inactive=1h
        use_temp_path=off;
    
    # Video cache
    proxy_cache_path /var/cache/nginx/video_cache
        levels=1:2
        keys_zone=video_cache:1g
        max_size=50g
        inactive=30d
        use_temp_path=off;
    
    # Assessment cache
    proxy_cache_path /var/cache/nginx/assessment_cache
        levels=1:2
        keys_zone=assessment_cache:200m
        max_size=2g
        inactive=1h
        use_temp_path=off;
    
    # =========================================================================
    # EDUCATION PLATFORM UPSTREAMS
    # =========================================================================
    # Course Service
    upstream course_service {
        least_conn;
        server courses1:8001 max_fails=3 fail_timeout=30s;
        server courses2:8001 max_fails=3 fail_timeout=30s;
        server courses3:8001 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Assessment Service
    upstream assessment_service {
        server assessment1:8002 max_fails=3 fail_timeout=30s;
        server assessment2:8002 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Video Service
    upstream video_service {
        server video1:8003 max_fails=3 fail_timeout=30s;
        server video2:8003 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Student Service
    upstream student_service {
        server student1:8004 max_fails=3 fail_timeout=30s;
        server student2:8004 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Collaboration Service
    upstream collaboration_service {
        server collab1:8005 max_fails=3 fail_timeout=30s;
        server collab2:8005 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Analytics Service
    upstream analytics_service {
        server analytics1:8006 max_fails=3 fail_timeout=30s;
        server analytics2:8006 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # RATE LIMITING
    # =========================================================================
    limit_req_zone $binary_remote_addr zone=course:10m rate=60r/m;
    limit_req_zone $binary_remote_addr zone=assessment:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=video:10m rate=30r/m;
    limit_req_zone $binary_remote_addr zone=collab:10m rate=100r/m;
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
    
    # =========================================================================
    # EDUCATION PLATFORM SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name learn.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/learn.crt;
        ssl_certificate_key /etc/nginx/ssl/learn.key;
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
        
        # Education platform headers
        add_header X-EdTech-Gateway "nginx" always;
        add_header X-EdTech-Version "2.0.0" always;
        
        # Global Rate Limiting
        limit_req zone=course burst=20 nodelay;
        limit_conn conn_limit 10;
        
        # =========================================================================
        # COURSE CATALOG
        # =========================================================================
        location /courses/ {
            # Course catalog with heavy caching
            proxy_cache course_cache;
            proxy_cache_key $scheme$host$request_uri$http_accept_language;
            proxy_cache_valid 200 302 10m;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://course_service/courses/;
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
        # LESSON CONTENT
        # =========================================================================
        location /lessons/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=course burst=10 nodelay;
            
            # Cache lesson content
            proxy_cache course_cache;
            proxy_cache_key $scheme$host$request_uri$auth_user_id;
            proxy_cache_valid 200 5m;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://course_service/lessons/;
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
        # VIDEO STREAMING
        # =========================================================================
        location /videos/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=video burst=5 nodelay;
            
            # Video caching
            proxy_cache video_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 30d;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            add_header X-Cache-Status $upstream_cache_status;
            
            # Support range requests
            proxy_pass http://video_service/videos/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            add_header Accept-Ranges bytes;
            
            proxy_connect_timeout 10s;
            proxy_read_timeout 300s;
            proxy_send_timeout 300s;
            
            # Large file support
            proxy_buffering on;
            proxy_buffer_size 16k;
            proxy_buffers 16 16k;
            proxy_busy_buffers_size 32k;
            proxy_max_temp_file_size 1024m;
        }
        
        # =========================================================================
        # ASSESSMENTS & QUIZZES
        # =========================================================================
        location /assessments/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=assessment burst=10 nodelay;
            
            # Cache assessment content
            if ($request_method = GET) {
                proxy_cache assessment_cache;
                proxy_cache_key $scheme$host$request_uri$auth_user_id;
                proxy_cache_valid 200 5m;
                add_header X-Cache-Status $upstream_cache_status;
            }
            
            proxy_pass http://assessment_service/assessments/;
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
            
            # No caching for POST
            if ($request_method = POST) {
                proxy_no_cache 1;
                proxy_cache_bypass 1;
                add_header Cache-Control "no-cache, no-store, must-revalidate";
            }
        }
        
        # =========================================================================
        # STUDENT PROGRESS
        # =========================================================================
        location /progress/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=course burst=10 nodelay;
            
            # Cache progress data
            proxy_cache assessment_cache;
            proxy_cache_key $scheme$host$request_uri$auth_user_id;
            proxy_cache_valid 200 30s;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://student_service/progress/;
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
        # REAL-TIME COLLABORATION (WEBSOCKET)
        # =========================================================================
        location /collab/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=collab burst=10 nodelay;
            
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
            
            proxy_pass http://collaboration_service/collab/;
        }
        
        # =========================================================================
        # STUDENT DASHBOARD
        # =========================================================================
        location /dashboard/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=course burst=10 nodelay;
            
            # Cache dashboard
            proxy_cache course_cache;
            proxy_cache_key $scheme$host$request_uri$auth_user_id;
            proxy_cache_valid 200 1m;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://student_service/dashboard/;
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
        # CERTIFICATES & BADGES
        # =========================================================================
        location /certificates/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=course burst=5 nodelay;
            
            # Cache certificates
            proxy_cache assessment_cache;
            proxy_cache_key $scheme$host$request_uri$auth_user_id;
            proxy_cache_valid 200 10m;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://course_service/certificates/;
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
        # ANALYTICS
        # =========================================================================
        location /analytics/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=course burst=10 nodelay;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            proxy_pass http://analytics_service/analytics/;
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
        # AUTH VALIDATION
        # =========================================================================
        location = /auth/validate {
            internal;
            
            proxy_pass http://student_service/validate;
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
        # EDUCATION PLATFORM STATUS
        # =========================================================================
        location /learn/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "service_status":{
                    "courses":$(curl -s -o /dev/null -w "%{http_code}" http://courses1:8001/health),
                    "assessment":$(curl -s -o /dev/null -w "%{http_code}" http://assessment1:8002/health),
                    "video":$(curl -s -o /dev/null -w "%{http_code}" http://video1:8003/health),
                    "student":$(curl -s -o /dev/null -w "%{http_code}" http://student1:8004/health),
                    "collab":$(curl -s -o /dev/null -w "%{http_code}" http://collab1:8005/health),
                    "analytics":$(curl -s -o /dev/null -w "%{http_code}" http://analytics1:8006/health)
                },
                "active_students":$(tail -10000 /var/log/nginx/access.log | grep -o '"X-User-ID":"[^"]*"' | cut -d'"' -f4 | sort -u | wc -l),
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

## P45.2 Interactive Learning Features

### Live Quiz Configuration

```nginx
# nginx-live-quiz.conf - Live Quiz Feature
# ============================================================================
# NGINX LIVE QUIZ CONFIGURATION
# Real-time quiz and assessment features
# ============================================================================

http {
    # =========================================================================
    # LIVE QUIZ UPSTREAMS
    # =========================================================================
    upstream quiz_service {
        least_conn;
        server quiz1:8007 max_fails=3 fail_timeout=30s;
        server quiz2:8007 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # =========================================================================
    # LIVE QUIZ ENDPOINTS
    # =========================================================================
    server {
        listen 443 ssl http2;
        server_name learn.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/learn.crt;
        ssl_certificate_key /etc/nginx/ssl/learn.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        
        # =========================================================================
        # LIVE QUIZ (WEBSOCKET)
        # =========================================================================
        location /quiz/live {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=assessment burst=10 nodelay;
            
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
            proxy_set_header X-Quiz-ID $http_x_quiz_id;
            
            proxy_buffering off;
            proxy_cache off;
            
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
            
            proxy_pass http://quiz_service/quiz/live;
        }
        
        # =========================================================================
        # QUIZ RESULTS
        # =========================================================================
        location /quiz/results {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=assessment burst=10 nodelay;
            
            # Cache results
            proxy_cache assessment_cache;
            proxy_cache_key $scheme$host$request_uri$auth_user_id$http_x_quiz_id;
            proxy_cache_valid 200 5m;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://quiz_service/quiz/results;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Quiz-ID $http_x_quiz_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
    }
}
```

## P45.3 Education Platform Monitoring

### EdTech Monitoring Dashboard

```bash
#!/bin/bash
# edtech-monitor.sh - Education platform monitoring

echo "=== Education Platform Monitoring Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get student stats
get_student_stats() {
    local students=$(tail -10000 /var/log/nginx/access.log | grep -o '"X-User-ID":"[^"]*"' | cut -d'"' -f4 | sort -u | wc -l)
    local courses=$(tail -10000 /var/log/nginx/access.log | grep -c "/courses/")
    local assessments=$(tail -10000 /var/log/nginx/access.log | grep -c "/assessments/")
    echo "  Student Statistics:"
    echo "    Active Students: $students"
    echo "    Courses Viewed: $courses"
    echo "    Assessments Taken: $assessments"
}

# Function: Get engagement metrics
get_engagement_metrics() {
    local videos=$(tail -10000 /var/log/nginx/access.log | grep -c "/videos/")
    local collab=$(tail -10000 /var/log/nginx/access.log | grep -c "/collab/")
    local progress=$(tail -10000 /var/log/nginx/access.log | grep -c "/progress/")
    echo "  Engagement Metrics:"
    echo "    Videos Watched: $videos"
    echo "    Collaboration Sessions: $collab"
    echo "    Progress Updates: $progress"
}

# Function: Get performance metrics
get_performance_metrics() {
    local avg_time=$(tail -100 /var/log/nginx/access.log | grep -o '"request_time":[0-9.]*' | cut -d':' -f2 | awk '{sum+=$1} END {if(NR>0) print sum/NR; else print 0}')
    local cache_hits=$(tail -1000 /var/log/nginx/access.log | grep -c '"X-Cache-Status":"HIT"')
    local total=$(tail -1000 /var/log/nginx/access.log | wc -l)
    local hit_rate=0
    if [ $total -gt 0 ]; then
        hit_rate=$((cache_hits * 100 / total))
    fi
    echo "  Performance Metrics:"
    echo "    Avg Response Time: ${avg_time}s"
    echo "    Cache Hit Rate: $hit_rate%"
}

# Function: Get service health
get_service_health() {
    echo "  Service Health:"
    for service in courses assessment video student collab analytics; do
        health=$(curl -s -o /dev/null -w "%{http_code}" "http://${service}1:8001/health" 2>/dev/null)
        if [ "$health" = "200" ]; then
            echo -e "    ${GREEN}✓ $service: healthy${NC}"
        else
            echo -e "    ${RED}✗ $service: unhealthy (HTTP $health)${NC}"
        fi
    done
}

# Main display
while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              EDUCATION PLATFORM MONITORING DASHBOARD          ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 STUDENT STATISTICS:"
    get_student_stats
    echo ""
    get_engagement_metrics
    echo ""
    get_performance_metrics
    echo ""
    get_service_health
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx for education and learning platforms. Use these techniques to build scalable, interactive, and secure educational technology solutions.
