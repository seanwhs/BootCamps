# Primer 30: Nginx for Internet of Things (IoT) Gateways

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx as an IoT gateway and device management platform. Understanding these concepts is essential for building scalable, secure, and reliable IoT infrastructures.

## P30.1 IoT Gateway Architecture

### Complete IoT Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    IoT GATEWAY ARCHITECTURE                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX IoT GATEWAY                              │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    DEVICE MANAGEMENT                      │ │      │
│  │  │  • Device Registration  • Device Authentication          │ │      │
│  │  │  • Device Provisioning  • Device Lifecycle              │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    DATA INGESTION                         │ │      │
│  │  │  • MQTT Protocol     • CoAP Protocol    • WebSocket       │ │      │
│  │  │  • HTTP/HTTPS        • Message Queue    • Streams        │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    COMMAND & CONTROL                     │ │      │
│  │  │  • Device Commands   • Firmware Updates  • Configuration │ │      │
│  │  │  • Remote Actions    • Scheduled Tasks   • Alerting      │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    PROTOCOL ADAPTERS                             │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ MQTT       │  │ CoAP       │  │ WebSocket  │  │ GRPC     │ │      │
│  │  │ Broker     │  │ Server     │  │ Server     │  │ Server   │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐           │
│  │              │              │              │              │           │
│  ▼              ▼              ▼              ▼              ▼           │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐           │
│  │ Device │  │ Device │  │ Device │  │ Device │  │ Device │           │
│  │ Registry│  │Data    │  │Command │  │Firmware│  │Analytics│           │
│  └────────┘  └────────┘  └────────┘  └────────┘  └────────┘           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete IoT Gateway Configuration

```nginx
# nginx-iot.conf - Complete IoT Gateway
# ============================================================================
# NGINX IOT GATEWAY
# Complete production-ready IoT configuration
# ============================================================================

http {
    # =========================================================================
    # IOT SPECIFIC SETTINGS
    # =========================================================================
    # Large body for device data
    client_max_body_size 100M;
    client_body_buffer_size 1M;
    client_header_buffer_size 4k;
    large_client_header_buffers 8 8k;
    
    # Long timeouts for device connections
    client_body_timeout 60s;
    client_header_timeout 60s;
    send_timeout 60s;
    keepalive_timeout 60;
    keepalive_requests 10000;
    
    # =========================================================================
    # DEVICE RATE LIMITING
    # =========================================================================
    limit_req_zone $binary_remote_addr zone=iot_ingest:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=iot_register:10m rate=1r/s;
    limit_conn_zone $binary_remote_addr zone=iot_conn:10m;
    
    # Device-specific rate limiting
    map $http_device_id $device_rate_limit {
        default iot_ingest;
        include /etc/nginx/device-rate-limits.conf;
    }
    
    # =========================================================================
    # DEVICE AUTHENTICATION
    # =========================================================================
    # Device ID extraction
    map $http_authorization $device_id {
        default "";
        "~^Bearer (?<token>.+)$" $token;
    }
    
    map $http_device_id $device_id_header {
        default "";
        "~^(?<id>.+)$" $id;
    }
    
    set $device_id $device_id;
    if ($device_id = "") {
        set $device_id $device_id_header;
    }
    
    # Device API key validation
    map $http_x_api_key $device_api_key {
        default "";
        "~^(?<key>.+)$" $key;
    }
    
    # =========================================================================
    # IOT UPSTREAMS
    # =========================================================================
    # Device Registration
    upstream device_registry {
        server registry:8001 max_fails=3 fail_timeout=30s;
        server registry-backup:8001 backup;
        keepalive 32;
    }
    
    # Data Ingestion
    upstream data_ingest {
        least_conn;
        server ingest1:8002 max_fails=3 fail_timeout=30s;
        server ingest2:8002 max_fails=3 fail_timeout=30s;
        server ingest3:8002 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Command & Control
    upstream command_service {
        server command:8003 max_fails=3 fail_timeout=30s;
        server command-backup:8003 backup;
        keepalive 32;
    }
    
    # Firmware Updates
    upstream firmware_service {
        server firmware:8004 max_fails=3 fail_timeout=30s;
        server firmware-backup:8004 backup;
        keepalive 32;
    }
    
    # Device Analytics
    upstream analytics_service {
        server analytics:8005 max_fails=3 fail_timeout=30s;
        keepalive 16;
    }
    
    # MQTT Bridge
    upstream mqtt_bridge {
        server mqtt:1883 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # IOT SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name iot.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/iot.crt;
        ssl_certificate_key /etc/nginx/ssl/iot.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1h;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        
        # IoT specific headers
        add_header X-IoT-Gateway "nginx" always;
        add_header X-IoT-Version "2.0.0" always;
        
        # =========================================================================
        # DEVICE REGISTRATION
        # =========================================================================
        location /device/register {
            # Strict rate limiting for registration
            limit_req zone=iot_register burst=1;
            limit_conn iot_conn 1;
            
            proxy_pass http://device_registry/device/register;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Device-ID $device_id;
            proxy_set_header X-Device-Type $http_device_type;
            proxy_set_header X-Device-Model $http_device_model;
            proxy_set_header X-Device-Version $http_device_version;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 10s;
            proxy_send_timeout 10s;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
        }
        
        # =========================================================================
        # DEVICE DATA INGESTION
        # =========================================================================
        location /ingest/ {
            # Rate limiting per device
            limit_req zone=$device_rate_limit burst=10 nodelay;
            limit_conn iot_conn 10;
            
            # Device authentication
            auth_request /device/validate;
            
            # Disable buffering for high-throughput
            proxy_buffering off;
            proxy_request_buffering off;
            
            proxy_pass http://data_ingest/ingest/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Device-ID $device_id;
            proxy_set_header X-Device-Type $http_device_type;
            proxy_set_header X-Timestamp $http_x_timestamp;
            proxy_set_header X-Signature $http_x_signature;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
            
            # No caching for sensor data
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
        }
        
        # =========================================================================
        # DEVICE COMMANDS
        # =========================================================================
        location /commands/ {
            auth_request /device/validate;
            
            proxy_pass http://command_service/commands/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Device-ID $device_id;
            proxy_set_header X-Command-ID $http_x_command_id;
            proxy_set_header X-Command-Type $http_x_command_type;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
        }
        
        # =========================================================================
        # FIRMWARE UPDATES
        # =========================================================================
        location /firmware/ {
            auth_request /device/validate;
            
            # Large file support
            client_max_body_size 1G;
            proxy_buffering on;
            proxy_buffer_size 16k;
            proxy_buffers 16 16k;
            proxy_busy_buffers_size 64k;
            
            # Cache firmware
            proxy_cache mobile_cache;
            proxy_cache_key $scheme$host$request_uri$device_id$http_device_version;
            proxy_cache_valid 200 7d;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://firmware_service/firmware/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Device-ID $device_id;
            proxy_set_header X-Firmware-Version $http_x_firmware_version;
            proxy_set_header X-Chunk $http_x_chunk;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 30s;
            proxy_read_timeout 300s;
            proxy_send_timeout 300s;
        }
        
        # =========================================================================
        # DEVICE VALIDATION
        # =========================================================================
        location = /device/validate {
            internal;
            
            proxy_pass http://device_registry/validate;
            proxy_pass_request_body off;
            
            proxy_set_header Content-Length "";
            proxy_set_header X-Original-URI $request_uri;
            proxy_set_header X-Device-ID $device_id;
            proxy_set_header X-API-Key $device_api_key;
            proxy_set_header Authorization $http_authorization;
            
            auth_request_set $device_status $upstream_http_x_device_status;
            auth_request_set $device_type $upstream_http_x_device_type;
            
            proxy_intercept_errors on;
            error_page 401 = /device-error;
            error_page 403 = /device-error;
        }
        
        # =========================================================================
        # DEVICE ERROR
        # =========================================================================
        location = /device-error {
            return 401 '{"error":"Device authentication failed"}';
            add_header Content-Type application/json;
        }
        
        # =========================================================================
        # MQTT BRIDGE
        # =========================================================================
        location /mqtt/ {
            # MQTT over WebSocket
            proxy_pass http://mqtt_bridge/mqtt/;
            
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Device-ID $device_id;
            
            proxy_buffering off;
            
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
        }
        
        # =========================================================================
        # DEVICE STATUS
        # =========================================================================
        location /device/status {
            auth_request /device/validate;
            
            proxy_pass http://device_registry/device/status;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Device-ID $device_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_cache mobile_cache;
            proxy_cache_key $scheme$host$request_uri$device_id;
            proxy_cache_valid 200 5s;
            add_header X-Cache-Status $upstream_cache_status;
        }
        
        # =========================================================================
        # DEVICE ANALYTICS
        # =========================================================================
        location /analytics/ {
            auth_request /device/validate;
            
            # Analytics ingestion
            limit_req zone=event_ingest burst=50 nodelay;
            
            proxy_buffering off;
            proxy_request_buffering off;
            
            proxy_pass http://analytics_service/analytics/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Device-ID $device_id;
            proxy_set_header X-Event-Type $http_x_event_type;
            proxy_set_header X-Event-Data $http_x_event_data;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 2s;
            proxy_read_timeout 5s;
            proxy_send_timeout 5s;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
        }
        
        # =========================================================================
        # IoT STATUS DASHBOARD
        # =========================================================================
        location /iot/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "active_devices":$(tail -10000 /var/log/nginx/access.log | grep -o '"X-Device-ID":"[^"]*"' | cut -d'"' -f4 | sort -u | wc -l),
                "ingestion_rate":$(tail -60 /var/log/nginx/access.log | grep -c "/ingest/"),
                "commands_sent":$(tail -10000 /var/log/nginx/access.log | grep -c "/commands/"),
                "firmware_updates":$(tail -10000 /var/log/nginx/access.log | grep -c "/firmware/"),
                "mqtt_connections":$(netstat -an | grep ':443' | grep ESTABLISHED | wc -l),
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

## P30.2 MQTT over WebSocket

### MQTT WebSocket Configuration

```nginx
# nginx-mqtt-ws.conf - MQTT over WebSocket
# ============================================================================
# NGINX MQTT WEBSOCKET BRIDGE
# Complete MQTT over WebSocket configuration
# ============================================================================

http {
    # =========================================================================
    # MQTT UPSTREAMS
    # =========================================================================
    upstream mqtt_broker {
        server mqtt-broker:1883 max_fails=3 fail_timeout=30s;
        server mqtt-broker-backup:1883 backup;
        keepalive 64;
    }
    
    # =========================================================================
    # MQTT WEBSOCKET SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        server_name mqtt.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/mqtt.crt;
        ssl_certificate_key /etc/nginx/ssl/mqtt.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;
        
        # WebSocket MQTT endpoint
        location /mqtt {
            # MQTT WebSocket upgrade
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            # MQTT specific headers
            proxy_set_header X-MQTT-Client-ID $http_x_mqtt_client_id;
            proxy_set_header X-MQTT-Username $http_x_mqtt_username;
            proxy_set_header X-MQTT-Password $http_x_mqtt_password;
            
            # Disable buffering
            proxy_buffering off;
            
            # Long timeouts for MQTT
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
            
            proxy_pass http://mqtt_broker;
        }
        
        # MQTT status endpoint
        location /mqtt/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "active_connections":$(netstat -an | grep ':443' | grep ESTABLISHED | wc -l),
                "mqtt_connected":$(netstat -an | grep ':1883' | grep ESTABLISHED | wc -l),
                "timestamp":"$time_iso8601"
            }';
            add_header Content-Type application/json;
        }
    }
}
```

## P30.3 IoT Monitoring Dashboard

### IoT Device Monitoring

```bash
#!/bin/bash
# iot-monitor.sh - IoT device monitoring

echo "=== IoT Monitoring Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get active devices
get_active_devices() {
    local devices=$(tail -10000 /var/log/nginx/access.log | \
        grep -o '"X-Device-ID":"[^"]*"' | \
        cut -d'"' -f4 | sort -u | wc -l)
    echo "  Active Devices: $devices"
}

# Function: Get device types
get_device_types() {
    echo "  Device Types:"
    tail -10000 /var/log/nginx/access.log | \
        grep -o '"X-Device-Type":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | head -5 | \
        while read count type; do
            echo "    $type: $count"
        done
}

# Function: Get device firmware versions
get_firmware_versions() {
    echo "  Firmware Versions:"
    tail -10000 /var/log/nginx/access.log | \
        grep -o '"X-Firmware-Version":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | head -5 | \
        while read count version; do
            echo "    $version: $count"
        done
}

# Function: Get data ingestion rate
get_ingestion_rate() {
    local rate=$(tail -60 /var/log/nginx/access.log | grep -c "/ingest/")
    echo "  Ingestion Rate: $((rate / 1)) messages/min"
}

# Function: Get command rate
get_command_rate() {
    local rate=$(tail -60 /var/log/nginx/access.log | grep -c "/commands/")
    echo "  Command Rate: $((rate / 1)) commands/min"
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
    echo "║              IOT DEVICE MONITORING DASHBOARD                  ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 IOT STATISTICS:"
    get_active_devices
    get_ingestion_rate
    get_command_rate
    get_error_rate
    echo ""
    
    echo "📈 DEVICE TYPES:"
    get_device_types
    echo ""
    
    echo "📦 FIRMWARE VERSIONS:"
    get_firmware_versions
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx as an IoT gateway and device management platform. Use these techniques to build scalable, secure, and reliable IoT infrastructures.
