# Primer 18: Nginx for Streaming & Media Delivery

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for streaming media delivery, including video-on-demand (VOD), live streaming, and adaptive bitrate (ABR) streaming. Understanding these concepts is essential for building modern media delivery platforms.

## P18.1 Streaming Architecture

### Complete Streaming Platform

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    STREAMING MEDIA ARCHITECTURE                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX STREAMING GATEWAY                       │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    STREAMING PROTOCOLS                     │ │      │
│  │  │  • RTMP        • HLS        • DASH        • WebRTC       │ │      │
│  │  │  • MPEG-DASH   • CMAF       • SRT         • RTP          │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    ADAPTIVE BITRATE                       │ │      │
│  │  │  • ABR Profiles   • Transcoding      • Packaging         │ │      │
│  │  │  • Bitrate Ladder • Content Steering • DRM               │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    CACHING & EDGE                         │ │      │
│  │  │  • Edge Delivery   • Cache Control      • Prefetch        │ │      │
│  │  │  • Content Caching • Geo Distribution  • CDN             │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐           │
│  │              │              │              │              │           │
│  ▼              ▼              ▼              ▼              ▼           │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐           │
│  │ VOD    │  │ Live   │  │ HLS    │  │ DASH   │  │ DRM    │           │
│  │ Content│  │ Events │  │ Origin │  │ Origin │  │ Server │           │
│  └────────┘  └────────┘  └────────┘  └────────┘  └────────┘           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## P18.2 HLS (HTTP Live Streaming)

### Complete HLS Configuration

```nginx
# nginx-hls.conf - Complete HLS Streaming Configuration
# ============================================================================
# NGINX HLS STREAMING SERVER
# Complete production-ready HLS configuration
# ============================================================================

# ============================================================================
# GLOBAL SETTINGS
# ============================================================================
user nginx;
worker_processes auto;
worker_rlimit_nofile 65535;

error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

# ============================================================================
# EVENTS
# ============================================================================
events {
    worker_connections 65535;
    use epoll;
    multi_accept on;
}

# ============================================================================
# HTTP BLOCK
# ============================================================================
http {
    # ------------------------------------------------------------------------
    # BASIC SETTINGS
    # ------------------------------------------------------------------------
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    server_tokens off;
    charset utf-8;

    # ------------------------------------------------------------------------
    # PERFORMANCE SETTINGS
    # ------------------------------------------------------------------------
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    # ------------------------------------------------------------------------
    # CACHE FOR HLS SEGMENTS
    # ------------------------------------------------------------------------
    proxy_cache_path /var/cache/nginx/hls_cache
        levels=1:2
        keys_zone=hls_cache:200m
        max_size=10g
        inactive=24h
        use_temp_path=off;

    proxy_cache_path /var/cache/nginx/hls_manifest_cache
        levels=1:2
        keys_zone=hls_manifest_cache:50m
        max_size=1g
        inactive=1h
        use_temp_path=off;

    # =========================================================================
    # HLS ORIGIN SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name hls.example.com;

        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/hls.crt;
        ssl_certificate_key /etc/nginx/ssl/hls.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
        ssl_prefer_server_ciphers off;

        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;

        # --------------------------------------------------------------------
        # LOCATION: HLS MANIFESTS (MASTER AND VARIANT)
        # --------------------------------------------------------------------
        location ~* \.(m3u8)$ {
            # Cache manifests
            proxy_cache hls_manifest_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 1h;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;

            add_header X-Cache-Status $upstream_cache_status;
            add_header Cache-Control "public, max-age=3600";

            # CORS headers
            add_header Access-Control-Allow-Origin "*" always;
            add_header Access-Control-Allow-Methods "GET, OPTIONS" always;
            add_header Access-Control-Allow-Headers "Range, Origin, Content-Type" always;

            proxy_pass http://hls-origin;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
        }

        # --------------------------------------------------------------------
        # LOCATION: HLS SEGMENTS (TS FILES)
        # --------------------------------------------------------------------
        location ~* \.(ts)$ {
            # Long-term caching for segments
            proxy_cache hls_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 24h;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;

            add_header X-Cache-Status $upstream_cache_status;
            add_header Cache-Control "public, max-age=86400, immutable";

            # CORS headers
            add_header Access-Control-Allow-Origin "*" always;
            add_header Access-Control-Allow-Methods "GET, OPTIONS" always;
            add_header Access-Control-Allow-Headers "Range, Origin, Content-Type" always;

            # Enable range requests for seeking
            add_header Accept-Ranges bytes;

            proxy_pass http://hls-origin;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;

            # Buffer settings for large files
            proxy_buffering on;
            proxy_buffer_size 16k;
            proxy_buffers 32 16k;
            proxy_busy_buffers_size 64k;
            proxy_max_temp_file_size 0;

            # Timeouts for large files
            proxy_connect_timeout 60s;
            proxy_read_timeout 300s;
            proxy_send_timeout 300s;
        }

        # --------------------------------------------------------------------
        # LOCATION: PRELOAD AND PREFETCH
        # --------------------------------------------------------------------
        location /prefetch/ {
            # Prefetch next segments
            internal;

            proxy_pass http://hls-origin;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
        }

        # --------------------------------------------------------------------
        # LOCATION: DRM LICENSES
        # --------------------------------------------------------------------
        location /drm/ {
            proxy_pass http://drm-server;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;

            # No caching for licenses
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-store, no-cache, must-revalidate";
        }

        # --------------------------------------------------------------------
        # LOCATION: HEALTH CHECK
        # --------------------------------------------------------------------
        location /health {
            access_log off;
            return 200 "healthy\n";
        }
    }

    # =========================================================================
    # HLS STREAMING METRICS
    # =========================================================================
    server {
        listen 127.0.0.1:9113;
        server_name localhost;

        location /metrics {
            stub_status on;
            access_log off;
            allow 127.0.0.1;
            deny all;
        }
    }
}

# ============================================================================
# STREAM BLOCK (RTMP)
# ============================================================================
stream {
    # RTMP Server for live streaming
    server {
        listen 1935;
        listen [::]:1935;

        proxy_pass rtmp_backend;
        proxy_timeout 60s;
        proxy_connect_timeout 5s;

        # RTMP specific settings
        proxy_buffer_size 16k;
        proxy_buffers 8 16k;
    }
}
```

## P18.3 DASH (MPEG-DASH)

### Complete DASH Configuration

```nginx
# nginx-dash.conf - Complete DASH Streaming Configuration
# ============================================================================
# NGINX MPEG-DASH STREAMING SERVER
# Complete production-ready DASH configuration
# ============================================================================

http {
    # =========================================================================
    # DASH SPECIFIC SETTINGS
    # =========================================================================
    
    # MIME types for DASH
    types {
        application/dash+xml mpd;
        video/mp4 mp4;
        video/mp4 m4s;
        video/mp4 m4v;
        audio/mp4 m4a;
        video/webm webm;
        video/webm m4s;
    }

    # DASH manifest cache
    proxy_cache_path /var/cache/nginx/dash_manifest_cache
        levels=1:2
        keys_zone=dash_manifest_cache:50m
        max_size=1g
        inactive=1h
        use_temp_path=off;

    # DASH segment cache
    proxy_cache_path /var/cache/nginx/dash_segment_cache
        levels=1:2
        keys_zone=dash_segment_cache:200m
        max_size=20g
        inactive=24h
        use_temp_path=off;

    # =========================================================================
    # DASH SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name dash.example.com;

        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/dash.crt;
        ssl_certificate_key /etc/nginx/ssl/dash.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
        ssl_prefer_server_ciphers off;

        # --------------------------------------------------------------------
        # LOCATION: DASH MANIFESTS
        # --------------------------------------------------------------------
        location ~* \.(mpd)$ {
            # Cache manifests
            proxy_cache dash_manifest_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 1h;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;

            add_header X-Cache-Status $upstream_cache_status;
            add_header Cache-Control "public, max-age=3600";
            add_header Access-Control-Allow-Origin "*" always;

            # CORS headers
            add_header Access-Control-Allow-Origin "*" always;
            add_header Access-Control-Allow-Methods "GET, OPTIONS" always;
            add_header Access-Control-Allow-Headers "Range, Origin, Content-Type" always;

            # Content steering
            add_header Content-Steering "application/dash+xml";

            proxy_pass http://dash-origin;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
        }

        # --------------------------------------------------------------------
        # LOCATION: DASH SEGMENTS
        # --------------------------------------------------------------------
        location ~* \.(m4s|mp4|m4v|m4a|webm)$ {
            # Cache segments
            proxy_cache dash_segment_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 24h;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;

            add_header X-Cache-Status $upstream_cache_status;
            add_header Cache-Control "public, max-age=86400, immutable";
            add_header Access-Control-Allow-Origin "*" always;
            add_header Accept-Ranges bytes;

            proxy_pass http://dash-origin;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;

            # Buffer settings
            proxy_buffering on;
            proxy_buffer_size 16k;
            proxy_buffers 32 16k;
            proxy_busy_buffers_size 64k;
            proxy_max_temp_file_size 0;

            # Timeouts
            proxy_connect_timeout 60s;
            proxy_read_timeout 300s;
            proxy_send_timeout 300s;
        }

        # --------------------------------------------------------------------
        # LOCATION: LOW LATENCY DASH (LL-DASH)
        # --------------------------------------------------------------------
        location /lldash/ {
            # Low-latency DASH settings
            proxy_cache off;
            proxy_buffering off;
            proxy_cache_bypass 1;
            proxy_no_cache 1;

            add_header Cache-Control "no-cache, no-store, must-revalidate";
            add_header Access-Control-Allow-Origin "*" always;

            proxy_pass http://dash-origin/lldash/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;

            # Short timeouts for low latency
            proxy_connect_timeout 2s;
            proxy_read_timeout 5s;
            proxy_send_timeout 5s;
        }

        # --------------------------------------------------------------------
        # LOCATION: CMAF (Common Media Application Format)
        # --------------------------------------------------------------------
        location /cmaf/ {
            # CMAF packaging
            proxy_pass http://cmaf-origin;

            add_header Access-Control-Allow-Origin "*" always;
            add_header Accept-Ranges bytes;

            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;

            # CMAF uses chunked encoding
            proxy_buffering off;
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
    }
}
```

## P18.4 Adaptive Bitrate (ABR) Configuration

### Bitrate Ladder Configuration

```nginx
# nginx-abl.conf - Adaptive Bitrate Ladder
# ============================================================================
# NGINX ADAPTIVE BITRATE LADDER
# Configuration for multi-bitrate streaming
# ============================================================================

http {
    # =========================================================================
    # BITRATE LADDER PROFILES
    # =========================================================================
    
    # Define ABR profiles
    map $http_user_agent $abr_profile {
        default "auto";
        ~*Mobile "mobile";
        ~*Tablet "tablet";
        ~*Desktop "desktop";
        ~*TV "tv";
    }

    # Bitrate ladder mapping
    map $abr_profile $bitrate_ladder {
        mobile "240p,360p,480p";
        tablet "360p,480p,720p";
        desktop "480p,720p,1080p";
        tv "720p,1080p,4K";
        default "480p,720p,1080p";
    }

    # Bitrate to resolution mapping
    map $bitrate $resolution {
        default "1080p";
        240p "426x240";
        360p "640x360";
        480p "854x480";
        720p "1280x720";
        1080p "1920x1080";
        4K "3840x2160";
    }

    # Bitrate to bandwidth mapping
    map $bitrate $bandwidth {
        default "5000";
        240p "300";
        360p "800";
        480p "1500";
        720p "3000";
        1080p "5000";
        4K "12000";
    }

    # =========================================================================
    # ABR PLAYBACK ROUTING
    # =========================================================================
    server {
        listen 443 ssl http2;
        server_name stream.example.com;

        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/stream.crt;
        ssl_certificate_key /etc/nginx/ssl/stream.key;
        ssl_protocols TLSv1.2 TLSv1.3;

        # --------------------------------------------------------------------
        # LOCATION: MASTER MANIFEST
        # --------------------------------------------------------------------
        location /master.m3u8 {
            # Generate master manifest with ABR variants
            add_header Content-Type "application/vnd.apple.mpegurl";
            add_header Cache-Control "public, max-age=3600";
            add_header Access-Control-Allow-Origin "*" always;

            # Return master manifest
            return 200 '
#EXTM3U
#EXT-X-VERSION:6
#EXT-X-STREAM-INF:BANDWIDTH=300000,RESOLUTION=426x240,CODECS="avc1.42e01e,mp4a.40.2"
/playlist/240p.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=640x360,CODECS="avc1.4d401e,mp4a.40.2"
/playlist/360p.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1500000,RESOLUTION=854x480,CODECS="avc1.4d401e,mp4a.40.2"
/playlist/480p.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=3000000,RESOLUTION=1280x720,CODECS="avc1.4d401f,mp4a.40.2"
/playlist/720p.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=5000000,RESOLUTION=1920x1080,CODECS="avc1.640028,mp4a.40.2"
/playlist/1080p.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=12000000,RESOLUTION=3840x2160,CODECS="hvc1.1.6.L153.B0,mp4a.40.2"
/playlist/4k.m3u8
';
        }

        # --------------------------------------------------------------------
        # LOCATION: BITRATE-SPECIFIC PLAYLISTS
        # --------------------------------------------------------------------
        location ~ ^/playlist/(?<bitrate>\w+)\.m3u8$ {
            # Serve bitrate-specific playlist
            add_header Content-Type "application/vnd.apple.mpegurl";
            add_header Cache-Control "public, max-age=3600";
            add_header Access-Control-Allow-Origin "*" always;

            # Generate segment URLs for the bitrate
            return 200 '
#EXTM3U
#EXT-X-VERSION:6
#EXT-X-TARGETDURATION:10
#EXT-X-MEDIA-SEQUENCE:0
#EXTINF:10.0,
/segments/{{bitrate}}/segment-0.ts
#EXTINF:10.0,
/segments/{{bitrate}}/segment-1.ts
#EXTINF:10.0,
/segments/{{bitrate}}/segment-2.ts
#EXT-X-ENDLIST
';
        }

        # --------------------------------------------------------------------
        # LOCATION: SEGMENT DELIVERY
        # --------------------------------------------------------------------
        location ~ ^/segments/(?<bitrate>\w+)/(?<segment>.+\.ts)$ {
            # Cache segments
            proxy_cache hls_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 24h;
            proxy_cache_use_stale error timeout updating;
            proxy_cache_lock on;

            add_header X-Cache-Status $upstream_cache_status;
            add_header Cache-Control "public, max-age=86400, immutable";
            add_header Access-Control-Allow-Origin "*" always;
            add_header Accept-Ranges bytes;

            proxy_pass http://origin/segments/$bitrate/$segment;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;

            # Buffer for large files
            proxy_buffering on;
            proxy_buffer_size 16k;
            proxy_buffers 32 16k;
            proxy_busy_buffers_size 64k;

            # Timeouts
            proxy_connect_timeout 60s;
            proxy_read_timeout 300s;
            proxy_send_timeout 300s;
        }
    }
}
```

## P18.5 Live Streaming Configuration

### Live Streaming with RTMP

```nginx
# nginx-rtmp.conf - RTMP Live Streaming
# ============================================================================
# NGINX RTMP LIVE STREAMING SERVER
# Complete production-ready RTMP configuration
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

        application live {
            live on;
            record off;
            
            # HLS publish
            hls on;
            hls_path /var/www/hls;
            hls_fragment 6s;
            hls_playlist_length 60s;
            hls_continuous on;
            hls_cleanup on;
            hls_nested on;
            hls_variant _low BANDWIDTH=300000;
            hls_variant _mid BANDWIDTH=1500000;
            hls_variant _high BANDWIDTH=5000000;

            # DASH publish
            dash on;
            dash_path /var/www/dash;
            dash_fragment 4s;
            dash_playlist_length 60s;
            dash_cleanup on;
            dash_nested on;

            # DRM
            on_publish http://drm-server/validate;
            on_play http://drm-server/authorize;

            # Authentication
            on_publish http://auth-server/validate;
            on_play http://auth-server/authorize;
        }

        application vod {
            play /var/www/vod;
            vod on;
            vod_metadata on;
        }

        application relay {
            live on;
            record off;
            
            push rtmp://backup-server/live;
            push rtmp://cdn-server/live;
        }
    }
}

http {
    # =========================================================================
    # HLS DELIVERY
    # =========================================================================
    server {
        listen 443 ssl http2;
        server_name live.example.com;

        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/live.crt;
        ssl_certificate_key /etc/nginx/ssl/live.key;
        ssl_protocols TLSv1.2 TLSv1.3;

        # HLS delivery
        location /hls/ {
            alias /var/www/hls/;
            add_header Cache-Control "public, max-age=3600";
            add_header Access-Control-Allow-Origin "*" always;
        }

        # DASH delivery
        location /dash/ {
            alias /var/www/dash/;
            add_header Cache-Control "public, max-age=3600";
            add_header Access-Control-Allow-Origin "*" always;
        }

        # VOD
        location /vod/ {
            alias /var/www/vod/;
            add_header Cache-Control "public, max-age=86400, immutable";
            add_header Access-Control-Allow-Origin "*" always;
        }

        # Health check
        location /health {
            access_log off;
            return 200 "healthy\n";
        }
    }
}
```

## P18.6 Streaming Analytics

### Streaming Analytics Script

```bash
#!/bin/bash
# streaming-analytics.sh - Real-time streaming analytics

echo "=== Streaming Analytics ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Functions
get_current_viewers() {
    local viewers=$(docker exec streaming-rtmp nginx -T 2>/dev/null | grep -c "client")
    echo "$viewers"
}

get_stream_health() {
    local health=$(curl -s http://localhost/health 2>/dev/null)
    if [[ $health == *"healthy"* ]]; then
        echo -e "${GREEN}HEALTHY${NC}"
    else
        echo -e "${RED}UNHEALTHY${NC}"
    fi
}

get_bitrate_stats() {
    # Parse access logs for bitrate information
    tail -100 /var/log/nginx/access.log | grep -E "m3u8|ts" | \
        awk '{sum+=$10; count++} END {if(count>0) print sum/count " bytes"; else print "0"}' 
}

get_buffer_stats() {
    # Monitor buffer fill rates
    tail -100 /var/log/nginx/access.log | grep "ts" | \
        awk '{print $11}' | sort | uniq -c
}

# Main display
while true; do
    clear
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              STREAMING ANALYTICS DASHBOARD                   ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 STREAM STATISTICS:"
    echo "  Viewers: $(get_current_viewers)"
    echo "  Health: $(get_stream_health)"
    echo "  Avg Bitrate: $(get_bitrate_stats)"
    echo ""
    
    echo "📈 PERFORMANCE:"
    echo "  Buffer Stats:"
    get_buffer_stats
    echo ""
    
    echo "💾 CACHE STATUS:"
    echo "  HLS Cache: $(du -sh /var/cache/nginx/hls_cache 2>/dev/null | cut -f1)"
    echo "  DASH Cache: $(du -sh /var/cache/nginx/dash_segment_cache 2>/dev/null | cut -f1)"
    echo ""
    
    echo "🔊 ACTIVE STREAMS:"
    curl -s http://localhost/metrics 2>/dev/null | grep -E "rtmp.*stream" | head -5
    
    echo ""
    echo "----------------------------------------"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx for streaming and media delivery. Use these techniques to build modern, scalable streaming platforms for VOD, live streaming, and adaptive bitrate delivery.
