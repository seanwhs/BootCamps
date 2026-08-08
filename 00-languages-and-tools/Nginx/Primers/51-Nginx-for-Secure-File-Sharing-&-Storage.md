# Primer 51: Nginx for Secure File Sharing & Storage

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for secure file sharing and storage platforms. Understanding these concepts is essential for building scalable, secure, and high-performance file storage and sharing solutions.

## P51.1 File Storage Architecture

### File Storage & Sharing Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    FILE STORAGE ARCHITECTURE                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX FILE GATEWAY                             │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    FILE MANAGEMENT                       │ │      │
│  │  │  • Upload          • Download        • Sync              │ │      │
│  │  │  • Versioning      • Metadata         • Sharing          │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    SECURITY & ENCRYPTION                  │ │      │
│  │  │  • Encryption      • Access Control    • Audit Logs      │ │      │
│  │  │  • Digital Signatures • Expiry          • Revocation     │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    PERFORMANCE OPTIMIZATION               │ │      │
│  │  │  • Edge Caching     • Compression       • Streaming       │ │      │
│  │  │  • Range Requests   • Prefetch         • Thumbnails      │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    FILE SERVICES                                 │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ Upload     │  │ Storage    │  │ Metadata   │  │ Sharing  │ │      │
│  │  │ Service    │  │ Service    │  │ Service    │  │ Service  │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete File Storage Configuration

```nginx
# nginx-file-storage.conf - Complete File Storage
# ============================================================================
# NGINX SECURE FILE SHARING & STORAGE
# Complete production-ready file storage configuration
# ============================================================================

http {
    # =========================================================================
    # FILE STORAGE SETTINGS
    # =========================================================================
    # Large file support
    client_max_body_size 10G;
    client_body_buffer_size 1M;
    client_body_timeout 300s;
    
    # Buffer settings
    client_header_buffer_size 4k;
    large_client_header_buffers 8 8k;
    
    # Timeouts for large files
    client_header_timeout 300s;
    send_timeout 300s;
    keepalive_timeout 65;
    keepalive_requests 1000;
    
    # =========================================================================
    # FILE CACHING
    # =========================================================================
    # File cache
    proxy_cache_path /var/cache/nginx/file_cache
        levels=1:2
        keys_zone=file_cache:1g
        max_size=100g
        inactive=30d
        use_temp_path=off;
    
    # Metadata cache
    proxy_cache_path /var/cache/nginx/metadata_cache
        levels=1:2
        keys_zone=metadata_cache:200m
        max_size=2g
        inactive=1h
        use_temp_path=off;
    
    # =========================================================================
    # FILE UPSTREAMS
    # =========================================================================
    # Upload Service
    upstream upload_service {
        least_conn;
        server upload1:8001 max_fails=3 fail_timeout=30s;
        server upload2:8001 max_fails=3 fail_timeout=30s;
        server upload3:8001 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Storage Service
    upstream storage_service {
        least_conn;
        server storage1:8002 max_fails=3 fail_timeout=30s;
        server storage2:8002 max_fails=3 fail_timeout=30s;
        server storage3:8002 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Metadata Service
    upstream metadata_service {
        server metadata1:8003 max_fails=3 fail_timeout=30s;
        server metadata2:8003 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Sharing Service
    upstream sharing_service {
        server sharing1:8004 max_fails=3 fail_timeout=30s;
        server sharing2:8004 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # RATE LIMITING
    # =========================================================================
    limit_req_zone $binary_remote_addr zone=upload:10m rate=10r/m;
    limit_req_zone $binary_remote_addr zone=download:10m rate=100r/m;
    limit_req_zone $binary_remote_addr zone=share:10m rate=10r/m;
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
    
    # =========================================================================
    # FILE SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name files.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/files.crt;
        ssl_certificate_key /etc/nginx/ssl/files.key;
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
        
        # File storage headers
        add_header X-File-Storage "nginx" always;
        add_header X-File-Storage-Version "2.0.0" always;
        
        # =========================================================================
        # FILE UPLOAD
        # =========================================================================
        location /upload/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=upload burst=2 nodelay;
            limit_conn conn_limit 5;
            
            # Upload settings
            client_max_body_size 10G;
            client_body_timeout 300s;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            proxy_pass http://upload_service/upload/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-File-Name $http_x_file_name;
            proxy_set_header X-File-Size $http_x_file_size;
            proxy_set_header X-File-Type $http_x_file_type;
            proxy_set_header X-File-MD5 $http_x_file_md5;
            proxy_set_header X-Chunk-Number $http_x_chunk_number;
            proxy_set_header X-Chunk-Total $http_x_chunk_total;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Buffer for large files
            proxy_buffering on;
            proxy_buffer_size 16k;
            proxy_buffers 16 16k;
            proxy_busy_buffers_size 32k;
            proxy_max_temp_file_size 10240m;
            
            proxy_connect_timeout 10s;
            proxy_read_timeout 300s;
            proxy_send_timeout 300s;
        }
        
        # =========================================================================
        # FILE DOWNLOAD
        # =========================================================================
        location /download/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=download burst=10 nodelay;
            
            # File caching
            proxy_cache file_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 30d;
            proxy_cache_valid 404 1m;
            proxy_cache_use_stale error timeout updating;
            add_header X-Cache-Status $upstream_cache_status;
            
            # Download headers
            add_header Cache-Control "public, max-age=86400";
            add_header Accept-Ranges bytes;
            add_header Content-Disposition "attachment; filename=\"$http_x_file_name\"";
            
            proxy_pass http://storage_service/download/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-File-ID $http_x_file_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Large file support
            proxy_buffering on;
            proxy_buffer_size 16k;
            proxy_buffers 16 16k;
            proxy_busy_buffers_size 32k;
            proxy_max_temp_file_size 10240m;
            
            proxy_connect_timeout 10s;
            proxy_read_timeout 300s;
            proxy_send_timeout 300s;
        }
        
        # =========================================================================
        # FILE STREAMING
        # =========================================================================
        location /stream/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=download burst=10 nodelay;
            
            # File caching
            proxy_cache file_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 30d;
            add_header X-Cache-Status $upstream_cache_status;
            
            # Streaming headers
            add_header Cache-Control "public, max-age=86400";
            add_header Accept-Ranges bytes;
            
            proxy_pass http://storage_service/stream/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-File-ID $http_x_file_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Streaming settings
            proxy_buffering on;
            proxy_buffer_size 16k;
            proxy_buffers 16 16k;
            proxy_busy_buffers_size 32k;
            proxy_max_temp_file_size 10240m;
            
            proxy_connect_timeout 10s;
            proxy_read_timeout 300s;
            proxy_send_timeout 300s;
        }
        
        # =========================================================================
        # FILE METADATA
        # =========================================================================
        location /metadata/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=download burst=10 nodelay;
            
            # Cache metadata
            proxy_cache metadata_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 5m;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://metadata_service/metadata/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-File-ID $http_x_file_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # FILE SHARING
        # =========================================================================
        location /share/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=share burst=2 nodelay;
            limit_conn conn_limit 2;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            proxy_pass http://sharing_service/share/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-File-ID $http_x_file_id;
            proxy_set_header X-Share-With $http_x_share_with;
            proxy_set_header X-Share-Permissions $http_x_share_permissions;
            proxy_set_header X-Share-Expiry $http_x_share_expiry;
            
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
            
            proxy_pass http://metadata_service/validate;
            proxy_pass_request_body off;
            
            proxy_set_header Content-Length "";
            proxy_set_header X-Original-URI $request_uri;
            proxy_set_header Authorization $http_authorization;
            proxy_set_header Cookie $http_cookie;
            proxy_set_header X-Session-ID $http_x_session_id;
            
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
        # FILE STATUS
        # =========================================================================
        location /file/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "service_status":{
                    "upload":$(curl -s -o /dev/null -w "%{http_code}" http://upload1:8001/health),
                    "storage":$(curl -s -o /dev/null -w "%{http_code}" http://storage1:8002/health),
                    "metadata":$(curl -s -o /dev/null -w "%{http_code}" http://metadata1:8003/health),
                    "sharing":$(curl -s -o /dev/null -w "%{http_code}" http://sharing1:8004/health)
                },
                "storage_usage":{
                    "total":$(du -sh /var/cache/nginx/file_cache | cut -f1),
                    "files":$(find /var/cache/nginx/file_cache -type f | wc -l)
                },
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

## P51.2 File Security & Encryption

### Secure File Configuration

```nginx
# nginx-file-security.conf - File Security
# ============================================================================
# NGINX FILE SECURITY & ENCRYPTION
# Complete file security configuration
# ============================================================================

http {
    # =========================================================================
    # FILE ENCRYPTION HEADERS
    # =========================================================================
    server {
        listen 443 ssl http2;
        server_name files.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/files.crt;
        ssl_certificate_key /etc/nginx/ssl/files.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;
        
        # =========================================================================
        # ENCRYPTION HEADERS
        # =========================================================================
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        add_header X-XSS-Protection "1; mode=block" always;
        
        # File security headers
        add_header X-File-Encryption "AES-256-GCM" always;
        add_header X-Content-Encryption "enabled" always;
        
        # =========================================================================
        # ACCESS CONTROL
        # =========================================================================
        location /secure/ {
            # Only allow encrypted connections
            if ($scheme != "https") {
                return 301 https://$host$request_uri;
            }
            
            # Strong authentication
            auth_basic "Secure File Access";
            auth_basic_user_file /etc/nginx/.htpasswd;
            
            # IP restrictions
            allow 10.0.0.0/8;
            allow 172.16.0.0/12;
            allow 192.168.0.0/16;
            deny all;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-store, no-cache, must-revalidate";
            add_header Pragma "no-cache";
            add_header Expires "0";
            
            proxy_pass http://secure_storage;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
        }
        
        # =========================================================================
        # FILE INTEGRITY
        # =========================================================================
        location /integrity/ {
            # File integrity checks
            add_header X-File-Checksum "sha256";
            
            proxy_pass http://integrity_service;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-File-ID $http_x_file_id;
            proxy_set_header X-Checksum $http_x_checksum;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
    }
}
```

## P51.3 File Storage Monitoring

### File Storage Dashboard

```bash
#!/bin/bash
# file-storage-monitor.sh - File storage monitoring

echo "=== File Storage Monitoring Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get storage statistics
get_storage_statistics() {
    local total_size=$(du -sh /var/cache/nginx/file_cache 2>/dev/null | cut -f1)
    local file_count=$(find /var/cache/nginx/file_cache -type f 2>/dev/null | wc -l)
    echo "  Storage Statistics:"
    echo "    Total Size: $total_size"
    echo "    File Count: $file_count"
}

# Function: Get upload statistics
get_upload_statistics() {
    local uploads=$(tail -10000 /var/log/nginx/access.log | grep -c "/upload/")
    local upload_size=$(tail -10000 /var/log/nginx/access.log | grep "/upload/" | grep -o '"X-File-Size":"[^"]*"' | cut -d'"' -f4 | awk '{sum+=$1} END {print sum}')
    echo "  Upload Statistics:"
    echo "    Files Uploaded: $uploads"
    echo "    Total Uploaded: ${upload_size}MB"
}

# Function: Get download statistics
get_download_statistics() {
    local downloads=$(tail -10000 /var/log/nginx/access.log | grep -c "/download/")
    local download_size=$(tail -10000 /var/log/nginx/access.log | grep "/download/" | grep -o '"X-File-Size":"[^"]*"' | cut -d'"' -f4 | awk '{sum+=$1} END {print sum}')
    echo "  Download Statistics:"
    echo "    Files Downloaded: $downloads"
    echo "    Total Downloaded: ${download_size}MB"
}

# Function: Get share statistics
get_share_statistics() {
    local shares=$(tail -10000 /var/log/nginx/access.log | grep -c "/share/")
    echo "  Sharing Statistics:"
    echo "    Files Shared: $shares"
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
    echo "║              FILE STORAGE MONITORING DASHBOARD                ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "💾 STORAGE:"
    get_storage_statistics
    echo ""
    echo "📤 UPLOADS:"
    get_upload_statistics
    echo ""
    echo "📥 DOWNLOADS:"
    get_download_statistics
    echo ""
    echo "🔗 SHARING:"
    get_share_statistics
    echo ""
    echo "⚡ CACHE:"
    get_cache_performance
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx for secure file sharing and storage platforms. Use these techniques to build scalable, secure, and high-performance file storage and sharing solutions.
