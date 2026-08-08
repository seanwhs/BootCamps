# Primer 48: Nginx for Video Streaming & VOD Platforms

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for video streaming and VOD (Video On Demand) platforms. Understanding these concepts is essential for building scalable, low-latency streaming platforms.

## P48.1 Video Streaming Architecture

### Streaming Platform Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    VIDEO STREAMING ARCHITECTURE                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX STREAMING GATEWAY                        │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    VIDEO DELIVERY                         │ │      │
│  │  │  • HLS Streaming    • DASH Streaming    • RTMP           │ │      │
│  │  │  • CMAF             • ABR Profiles      • DRM            │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    CONTENT MANAGEMENT                     │ │      │
│  │  │  • VOD Catalog       • Live Events        • Playlists     │ │      │
│  │  │  • Transcoding       • Packaging          • Thumbnails    │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    PERFORMANCE OPTIMIZATION               │ │      │
│  │  │  • Edge Caching      • CDN Integration    • Prefetching   │ │      │
│  │  │  • Bitrate Steering  • Manifest Manipulation• Analytics   │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    VIDEO SERVICES                                 │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ VOD        │  │ Live       │  │ Transcode  │  │ DRM      │ │      │
│  │  │ Service    │  │ Service    │  │ Service    │  │ Service  │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Video Streaming Configuration

```nginx
# nginx-video-streaming.conf - Complete Video Streaming
# ============================================================================
# NGINX VIDEO STREAMING & VOD PLATFORM
# Complete production-ready streaming configuration
# ============================================================================

http {
    # =========================================================================
    # STREAMING SPECIFIC SETTINGS
    # =========================================================================
    # Large file support
    client_max_body_size 1G;
    client_body_buffer_size 1M;
    
    # Buffer settings
    client_header_buffer_size 4k;
    large_client_header_buffers 8 8k;
    
    # Timeouts for large files
    client_body_timeout 300s;
    client_header_timeout 300s;
    send_timeout 300s;
    keepalive_timeout 65;
    keepalive_requests 1000;
    
    # =========================================================================
    # STREAMING CACHING
    # =========================================================================
    # Video segment cache
    proxy_cache_path /var/cache/nginx/video_cache
        levels=1:2
        keys_zone=video_cache:2g
        max_size=100g
        inactive=30d
        use_temp_path=off;
    
    # Manifest cache
    proxy_cache_path /var/cache/nginx/manifest_cache
        levels=1:2
        keys_zone=manifest_cache:200m
        max_size=2g
        inactive=1h
        use_temp_path=off;
    
    # =========================================================================
    # STREAMING UPSTREAMS
    # =========================================================================
    # VOD Service
    upstream vod_service {
        least_conn;
        server vod1:8001 max_fails=3 fail_timeout=30s;
        server vod2:8001 max_fails=3 fail_timeout=30s;
        server vod3:8001 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Live Streaming Service
    upstream live_service {
        least_conn;
        server live1:8002 max_fails=3 fail_timeout=30s;
        server live2:8002 max_fails=3 fail_timeout=30s;
        server live3:8002 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Transcoding Service
    upstream transcode_service {
        server transcode1:8003 max_fails=3 fail_timeout=30s;
        server transcode2:8003 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # DRM Service
    upstream drm_service {
        server drm1:8004 max_fails=3 fail_timeout=30s;
        server drm2:8004 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # STREAMING SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name video.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/video.crt;
        ssl_certificate_key /etc/nginx/ssl/video.key;
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
        
        # Streaming headers
        add_header X-Streaming-Gateway "nginx" always;
        add_header X-Streaming-Version "2.0.0" always;
        
        # =========================================================================
        # MIME TYPES
        # =========================================================================
        types {
            application/vnd.apple.mpegurl m3u8;
            video/mp2t ts;
            application/dash+xml mpd;
            video/mp4 mp4;
        }
        
        # =========================================================================
        # CORS FOR STREAMING
        # =========================================================================
        add_header Access-Control-Allow-Origin "*" always;
        add_header Access-Control-Allow-Methods "GET, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID" always;
        add_header Access-Control-Expose-Headers "X-Request-ID, X-Segment-Count, X-Duration" always;
        
        # Preflight
        if ($request_method = 'OPTIONS') {
            add_header Access-Control-Allow-Origin "*" always;
            add_header Access-Control-Allow-Methods "GET, OPTIONS" always;
            add_header Access-Control-Allow-Headers "Authorization, Content-Type, X-Request-ID" always;
            add_header Access-Control-Max-Age 86400;
            add_header Content-Length 0;
            return 204;
        }
        
        # =========================================================================
        # HLS MANIFEST
        # =========================================================================
        location ~* \.m3u8$ {
            # Cache manifests
            proxy_cache manifest_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 1h;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            add_header X-Cache-Status $upstream_cache_status;
            
            # Manifest headers
            add_header Cache-Control "public, max-age=3600";
            add_header Content-Type "application/vnd.apple.mpegurl";
            
            # Serve manifests
            proxy_pass http://vod_service;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # =========================================================================
        # HLS SEGMENTS
        # =========================================================================
        location ~* \.ts$ {
            # Long-term caching for segments
            proxy_cache video_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 30d;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            add_header X-Cache-Status $upstream_cache_status;
            
            # Segment headers
            expires 30d;
            add_header Cache-Control "public, immutable";
            add_header Accept-Ranges bytes;
            add_header Content-Type "video/mp2t";
            
            # Serve segments
            proxy_pass http://vod_service;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Large file support
            proxy_buffering on;
            proxy_buffer_size 16k;
            proxy_buffers 16 16k;
            proxy_busy_buffers_size 32k;
            proxy_max_temp_file_size 1024m;
            
            proxy_connect_timeout 10s;
            proxy_read_timeout 300s;
            proxy_send_timeout 300s;
        }
        
        # =========================================================================
        # DASH MANIFEST
        # =========================================================================
        location ~* \.mpd$ {
            # Cache DASH manifests
            proxy_cache manifest_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 1h;
            add_header X-Cache-Status $upstream_cache_status;
            
            add_header Cache-Control "public, max-age=3600";
            add_header Content-Type "application/dash+xml";
            
            proxy_pass http://vod_service;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # =========================================================================
        # DASH SEGMENTS
        # =========================================================================
        location ~* \.(m4s|mp4|webm)$ {
            # Cache DASH segments
            proxy_cache video_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 30d;
            add_header X-Cache-Status $upstream_cache_status;
            
            expires 30d;
            add_header Cache-Control "public, immutable";
            add_header Accept-Ranges bytes;
            
            proxy_pass http://vod_service;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_buffering on;
            proxy_buffer_size 16k;
            proxy_buffers 16 16k;
            proxy_busy_buffers_size 32k;
            proxy_max_temp_file_size 1024m;
            
            proxy_connect_timeout 10s;
            proxy_read_timeout 300s;
            proxy_send_timeout 300s;
        }
        
        # =========================================================================
        # LIVE STREAMING (RTMP/HLS)
        # =========================================================================
        location /live/ {
            # Live streaming
            proxy_cache off;
            proxy_buffering off;
            proxy_request_buffering off;
            
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            add_header X-Accel-Buffering "no";
            
            # Live HLS
            location /live/hls/ {
                alias /var/www/live/hls/;
                add_header Cache-Control "no-cache, no-store, must-revalidate";
                add_header Access-Control-Allow-Origin "*";
            }
            
            # Live DASH
            location /live/dash/ {
                alias /var/www/live/dash/;
                add_header Cache-Control "no-cache, no-store, must-revalidate";
                add_header Access-Control-Allow-Origin "*";
            }
            
            proxy_pass http://live_service/live/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
        }
        
        # =========================================================================
        # DRM LICENSE
        # =========================================================================
        location /drm/ {
            # DRM license acquisition
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            proxy_pass http://drm_service/drm/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Content-ID $http_x_content_id;
            proxy_set_header X-KID $http_x_kid;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 10s;
            proxy_send_timeout 10s;
        }
        
        # =========================================================================
        # ADAPTIVE BITRATE
        # =========================================================================
        location /abr/ {
            # Adaptive bitrate steering
            proxy_pass http://vod_service/abr/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Bitrate $http_x_bitrate;
            proxy_set_header X-Bandwidth $http_x_bandwidth;
            proxy_set_header X-Device-Type $http_x_device_type;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # =========================================================================
        # THUMBNAILS
        # =========================================================================
        location ~* \.jpg$ {
            # Cache thumbnails
            proxy_cache video_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 30d;
            add_header X-Cache-Status $upstream_cache_status;
            
            expires 30d;
            add_header Cache-Control "public, immutable";
            
            proxy_pass http://vod_service;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # =========================================================================
        # PREVIEW (SUBTITLES)
        # =========================================================================
        location /subtitles/ {
            # Cache subtitles
            proxy_cache video_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 30d;
            add_header X-Cache-Status $upstream_cache_status;
            
            expires 30d;
            add_header Cache-Control "public, immutable";
            
            proxy_pass http://vod_service/subtitles/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Language $http_x_language;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # =========================================================================
        # STREAMING STATUS
        # =========================================================================
        location /streaming/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "service_status":{
                    "vod":$(curl -s -o /dev/null -w "%{http_code}" http://vod1:8001/health),
                    "live":$(curl -s -o /dev/null -w "%{http_code}" http://live1:8002/health),
                    "transcode":$(curl -s -o /dev/null -w "%{http_code}" http://transcode1:8003/health),
                    "drm":$(curl -s -o /dev/null -w "%{http_code}" http://drm1:8004/health)
                },
                "cache_status":{
                    "video_cache_size":"$(du -sh /var/cache/nginx/video_cache | cut -f1)",
                    "manifest_cache_size":"$(du -sh /var/cache/nginx/manifest_cache | cut -f1)"
                },
                "active_streams":$(tail -10000 /var/log/nginx/access.log | grep -c "/live/"),
                "vod_views":$(tail -10000 /var/log/nginx/access.log | grep -c "/vod/"),
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

## P48.2 Live Streaming

### RTMP Configuration

```nginx
# nginx-rtmp.conf - RTMP Live Streaming
# ============================================================================
# NGINX RTMP LIVE STREAMING
# Complete RTMP configuration for live streaming
# ============================================================================

rtmp {
    server {
        listen 1935;
        listen [::]:1935;
        chunk_size 4096;
        ping 30s;
        ping_timeout 10s;
        max_connections 1000;
        max_streams 100;
        
        # Live streaming application
        application live {
            live on;
            record off;
            
            # HLS output
            hls on;
            hls_path /var/www/live/hls;
            hls_fragment 6s;
            hls_playlist_length 60s;
            hls_continuous on;
            hls_cleanup on;
            hls_nested on;
            
            # ABR profiles
            hls_variant _low BANDWIDTH=300000;
            hls_variant _mid BANDWIDTH=1500000;
            hls_variant _high BANDWIDTH=5000000;
            
            # DASH output
            dash on;
            dash_path /var/www/live/dash;
            dash_fragment 4s;
            dash_playlist_length 60s;
            dash_cleanup on;
            dash_nested on;
            
            # Authentication
            on_publish http://auth-service/validate;
            on_play http://auth-service/authorize;
            
            # DRM
            on_publish_done http://drm-service/cleanup;
        }
        
        # VOD streaming
        application vod {
            play /var/www/vod;
            vod on;
            vod_metadata on;
        }
        
        # Relay to CDN
        application relay {
            live on;
            record off;
            
            push rtmp://cdn-server/live;
            push rtmp://backup-server/live;
        }
    }
}
```

## P48.3 Video Analytics

### Streaming Analytics Dashboard

```bash
#!/bin/bash
# video-analytics.sh - Video streaming analytics

echo "=== Video Streaming Analytics Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get view statistics
get_view_statistics() {
    local vod_views=$(tail -10000 /var/log/nginx/access.log | grep -c "/vod/")
    local live_views=$(tail -10000 /var/log/nginx/access.log | grep -c "/live/")
    echo "  View Statistics:"
    echo "    VOD Views: $vod_views"
    echo "    Live Views: $live_views"
}

# Function: Get bitrate distribution
get_bitrate_distribution() {
    echo "  Bitrate Distribution:"
    tail -10000 /var/log/nginx/access.log | \
        grep -o '"X-Bitrate":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | head -5 | \
        while read count bitrate; do
            echo "    $bitrate: $count"
        done
}

# Function: Get device types
get_device_types() {
    echo "  Device Types:"
    tail -10000 /var/log/nginx/access.log | \
        grep -o '"X-Device-Type":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | head -5 | \
        while read count device; do
            echo "    $device: $count"
        done
}

# Function: Get cache performance
get_cache_performance() {
    local video_hits=$(tail -1000 /var/log/nginx/access.log | grep "/vod/" | grep -c '"X-Cache-Status":"HIT"')
    local video_total=$(tail -1000 /var/log/nginx/access.log | grep -c "/vod/")
    if [ $video_total -gt 0 ]; then
        local rate=$((video_hits * 100 / video_total))
        echo "  Video Cache Hit Rate: $rate%"
    else
        echo "  Video Cache Hit Rate: N/A"
    fi
}

# Main display
while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              VIDEO STREAMING ANALYTICS DASHBOARD              ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 VIEW STATISTICS:"
    get_view_statistics
    echo ""
    get_bitrate_distribution
    echo ""
    get_device_types
    echo ""
    get_cache_performance
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx for video streaming and VOD platforms. Use these techniques to build scalable, low-latency streaming platforms.
