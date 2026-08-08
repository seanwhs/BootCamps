# Primer 49: Nginx for Real-Time Voice & Audio Processing

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for real-time voice and audio processing applications. Understanding these concepts is essential for building VoIP, conferencing, and audio streaming platforms.

## P49.1 Voice Processing Architecture

### Audio & Voice Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    VOICE PROCESSING ARCHITECTURE                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX VOICE GATEWAY                            │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    AUDIO PROCESSING                       │ │      │
│  │  │  • WebRTC            • VoIP               • Transcoding    │ │      │
│  │  │  • Echo Cancellation • Noise Reduction    • Mixing        │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    CONFERENCE MANAGEMENT                   │ │      │
│  │  │  • Room Creation    • Participant Sync    • Mute/Unmute    │ │      │
│  │  │  • Recording         • Transcription      • Transcription  │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    STREAMING & DELIVERY                    │ │      │
│  │  │  • WebSocket         • UDP/TCP           • RTCP           │ │      │
│  │  │  • WebRTC            • SIP               • RTP            │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    AUDIO SERVICES                                 │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ WebRTC     │  │ Conference │  │ Recording  │  │ Speech   │ │      │
│  │  │ Service    │  │ Service    │  │ Service    │  │ Service  │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Voice Processing Configuration

```nginx
# nginx-voice.conf - Complete Voice Processing
# ============================================================================
# NGINX REAL-TIME VOICE & AUDIO PROCESSING
# Complete production-ready voice configuration
# ============================================================================

http {
    # =========================================================================
    # VOICE PROCESSING SETTINGS
    # =========================================================================
    # Audio payload sizes
    client_max_body_size 10M;
    client_body_buffer_size 128k;
    
    # Buffer settings for real-time
    client_header_buffer_size 4k;
    large_client_header_buffers 8 8k;
    
    # Timeouts for real-time
    client_body_timeout 30s;
    client_header_timeout 30s;
    send_timeout 30s;
    keepalive_timeout 300s;
    keepalive_requests 10000;
    
    # =========================================================================
    # VOICE UPSTREAMS
    # =========================================================================
    # WebRTC Service
    upstream webrtc_service {
        least_conn;
        server webrtc1:8001 max_fails=3 fail_timeout=30s;
        server webrtc2:8001 max_fails=3 fail_timeout=30s;
        server webrtc3:8001 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Conference Service
    upstream conference_service {
        least_conn;
        server conf1:8002 max_fails=3 fail_timeout=30s;
        server conf2:8002 max_fails=3 fail_timeout=30s;
        server conf3:8002 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Recording Service
    upstream recording_service {
        server rec1:8003 max_fails=3 fail_timeout=30s;
        server rec2:8003 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Speech Service
    upstream speech_service {
        server speech1:8004 max_fails=3 fail_timeout=30s;
        server speech2:8004 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # RATE LIMITING
    # =========================================================================
    limit_req_zone $binary_remote_addr zone=webrtc:10m rate=20r/m;
    limit_req_zone $binary_remote_addr zone=conference:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=recording:10m rate=10r/m;
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
    
    # =========================================================================
    # VOICE SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name voice.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/voice.crt;
        ssl_certificate_key /etc/nginx/ssl/voice.key;
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
        
        # Voice headers
        add_header X-Voice-Gateway "nginx" always;
        add_header X-Voice-Version "2.0.0" always;
        
        # =========================================================================
        # WEBRTC SIGNALING
        # =========================================================================
        location /webrtc/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=webrtc burst=2 nodelay;
            limit_conn conn_limit 2;
            
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
            proxy_set_header X-Room-ID $http_x_room_id;
            proxy_set_header X-ICE-Candidates $http_x_ice_candidates;
            
            proxy_buffering off;
            proxy_cache off;
            
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
            
            proxy_pass http://webrtc_service/webrtc/;
        }
        
        # =========================================================================
        # CONFERENCE ROOMS
        # =========================================================================
        location /conference/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=conference burst=10 nodelay;
            
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
            proxy_set_header X-Room-ID $http_x_room_id;
            proxy_set_header X-Audio-Settings $http_x_audio_settings;
            
            proxy_buffering off;
            proxy_cache off;
            
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
            
            proxy_pass http://conference_service/conference/;
        }
        
        # =========================================================================
        # AUDIO RECORDING
        # =========================================================================
        location /recording/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=recording burst=2 nodelay;
            limit_conn conn_limit 2;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            proxy_pass http://recording_service/recording/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Room-ID $http_x_room_id;
            proxy_set_header X-Recording-Settings $http_x_recording_settings;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
        }
        
        # =========================================================================
        # SPEECH TRANSCRIPTION
        # =========================================================================
        location /speech/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=conference burst=10 nodelay;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            proxy_pass http://speech_service/speech/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Audio-Format $http_x_audio_format;
            proxy_set_header X-Language $http_x_language;
            proxy_set_header X-Transcription-Format $http_x_transcription_format;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # AUDIO STREAMING (WEBRTC)
        # =========================================================================
        location /audio/stream/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=webrtc burst=10 nodelay;
            
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
            proxy_set_header X-Stream-ID $http_x_stream_id;
            proxy_set_header X-Audio-Codec $http_x_audio_codec;
            
            proxy_buffering off;
            proxy_cache off;
            
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
            
            proxy_pass http://webrtc_service/audio/stream/;
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
        # VOICE STATUS
        # =========================================================================
        location /voice/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "service_status":{
                    "webrtc":$(curl -s -o /dev/null -w "%{http_code}" http://webrtc1:8001/health),
                    "conference":$(curl -s -o /dev/null -w "%{http_code}" http://conf1:8002/health),
                    "recording":$(curl -s -o /dev/null -w "%{http_code}" http://rec1:8003/health),
                    "speech":$(curl -s -o /dev/null -w "%{http_code}" http://speech1:8004/health)
                },
                "active_rooms":$(tail -10000 /var/log/nginx/access.log | grep -o '"X-Room-ID":"[^"]*"' | cut -d'"' -f4 | sort -u | wc -l),
                "active_participants":$(tail -10000 /var/log/nginx/access.log | grep -o '"X-User-ID":"[^"]*"' | cut -d'"' -f4 | sort -u | wc -l),
                "active_connections":$(netstat -an | grep ':443' | grep ESTABLISHED | wc -l),
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

## P49.2 WebRTC Specific Configuration

### WebRTC Optimization

```nginx
# nginx-webrtc.conf - WebRTC Optimization
# ============================================================================
# NGINX WEBRTC CONFIGURATION
# Complete WebRTC optimization for real-time voice
# ============================================================================

http {
    # =========================================================================
    # WEBRTC HEADERS
    # =========================================================================
    server {
        listen 443 ssl http2;
        server_name webrtc.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/webrtc.crt;
        ssl_certificate_key /etc/nginx/ssl/webrtc.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;
        
        # WebRTC headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        add_header X-XSS-Protection "1; mode=block" always;
        
        # =========================================================================
        # WEBRTC SIGNALING
        # =========================================================================
        location /webrtc/signaling {
            # WebSocket upgrade
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            # Disable buffering
            proxy_buffering off;
            proxy_cache off;
            
            # Long timeouts
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
            
            proxy_pass http://webrtc_service/signaling;
        }
        
        # =========================================================================
        # ICE CONFIGURATION
        # =========================================================================
        location /webrtc/ice {
            # ICE candidate exchange
            proxy_pass http://webrtc_service/ice;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-ICE-Candidates $http_x_ice_candidates;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
        }
        
        # =========================================================================
        # WEBRTC MEDIA
        # =========================================================================
        location /webrtc/media {
            # Media relay/proxy
            proxy_pass http://webrtc_service/media;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Media-Type $http_x_media_type;
            proxy_set_header X-SSRC $http_x_ssrc;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Disable buffering for media
            proxy_buffering off;
            proxy_cache off;
            
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
        }
    }
}
```

## P49.3 Voice Quality Monitoring

### Voice Quality Dashboard

```bash
#!/bin/bash
# voice-quality-monitor.sh - Voice quality monitoring

echo "=== Voice Quality Monitoring Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get audio quality metrics
get_audio_quality_metrics() {
    local packet_loss=$(tail -1000 /var/log/nginx/access.log | grep -o '"X-Packet-Loss":"[^"]*"' | cut -d'"' -f4 | awk '{sum+=$1} END {if(NR>0) print sum/NR; else print 0}')
    local jitter=$(tail -1000 /var/log/nginx/access.log | grep -o '"X-Jitter":"[^"]*"' | cut -d'"' -f4 | awk '{sum+=$1} END {if(NR>0) print sum/NR; else print 0}')
    echo "  Audio Quality Metrics:"
    echo "    Avg Packet Loss: ${packet_loss}%"
    echo "    Avg Jitter: ${jitter}ms"
}

# Function: Get codec distribution
get_codec_distribution() {
    echo "  Codec Distribution:"
    tail -10000 /var/log/nginx/access.log | \
        grep -o '"X-Audio-Codec":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | head -5 | \
        while read count codec; do
            echo "    $codec: $count"
        done
}

# Function: Get active rooms
get_active_rooms() {
    local rooms=$(tail -10000 /var/log/nginx/access.log | grep -o '"X-Room-ID":"[^"]*"' | cut -d'"' -f4 | sort -u | wc -l)
    echo "  Active Rooms: $rooms"
}

# Function: Get participants
get_participants() {
    local participants=$(tail -10000 /var/log/nginx/access.log | grep -o '"X-User-ID":"[^"]*"' | cut -d'"' -f4 | sort -u | wc -l)
    echo "  Active Participants: $participants"
}

# Main display
while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              VOICE QUALITY MONITORING DASHBOARD               ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "🎵 AUDIO QUALITY:"
    get_audio_quality_metrics
    echo ""
    get_codec_distribution
    echo ""
    get_active_rooms
    get_participants
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx for real-time voice and audio processing applications. Use these techniques to build VoIP, conferencing, and audio streaming platforms.
