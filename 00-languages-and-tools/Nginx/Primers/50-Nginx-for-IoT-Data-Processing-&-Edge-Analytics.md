# Primer 50: Nginx for IoT Data Processing & Edge Analytics

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for IoT data processing and edge analytics. Understanding these concepts is essential for building scalable, low-latency IoT platforms.

## P50.1 IoT Data Processing Architecture

### IoT Processing Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    IOT DATA PROCESSING ARCHITECTURE                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX IOT GATEWAY                              │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    DATA INGESTION                         │ │      │
│  │  │  • MQTT             • CoAP               • HTTP/HTTPS    │ │      │
│  │  │  • WebSocket        • GRPC               • UDP           │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    DATA PROCESSING                        │ │      │
│  │  │  • Filtering       • Aggregation        • Transformation  │ │      │
│  │  │  • Analytics       • ML Inference       • Alerts         │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    DEVICE MANAGEMENT                      │ │      │
│  │  │  • Provisioning    • Firmware Updates   • Monitoring      │ │      │
│  │  │  • Configuration    • Diagnostics       • Security        │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    IOT SERVICES                                  │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ Device     │  │ Data       │  │ Analytics  │  │ Command  │ │      │
│  │  │ Service    │  │ Service    │  │ Service    │  │ Service  │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete IoT Data Processing Configuration

```nginx
# nginx-iot-processing.conf - Complete IoT Processing
# ============================================================================
# NGINX IOT DATA PROCESSING & EDGE ANALYTICS
# Complete production-ready IoT configuration
# ============================================================================

http {
    # =========================================================================
    # IOT SPECIFIC SETTINGS
    # =========================================================================
    # Large payloads for sensor data
    client_max_body_size 50M;
    client_body_buffer_size 1M;
    
    # Buffer settings
    client_header_buffer_size 4k;
    large_client_header_buffers 8 8k;
    
    # Timeouts for IoT devices
    client_body_timeout 60s;
    client_header_timeout 60s;
    send_timeout 60s;
    keepalive_timeout 65;
    keepalive_requests 1000;
    
    # =========================================================================
    # IOT CACHING
    # =========================================================================
    # Sensor data cache
    proxy_cache_path /var/cache/nginx/sensor_cache
        levels=1:2
        keys_zone=sensor_cache:500m
        max_size=10g
        inactive=1h
        use_temp_path=off;
    
    # Device state cache
    proxy_cache_path /var/cache/nginx/device_cache
        levels=1:2
        keys_zone=device_cache:200m
        max_size=2g
        inactive=5m
        use_temp_path=off;
    
    # =========================================================================
    # IOT UPSTREAMS
    # =========================================================================
    # Device Service
    upstream device_service {
        least_conn;
        server device1:8001 max_fails=3 fail_timeout=30s;
        server device2:8001 max_fails=3 fail_timeout=30s;
        server device3:8001 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Data Ingestion Service
    upstream data_service {
        least_conn;
        server data1:8002 max_fails=3 fail_timeout=30s;
        server data2:8002 max_fails=3 fail_timeout=30s;
        server data3:8002 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Analytics Service
    upstream analytics_service {
        least_conn;
        server analytics1:8003 max_fails=3 fail_timeout=30s;
        server analytics2:8003 max_fails=3 fail_timeout=30s;
        server analytics3:8003 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Command Service
    upstream command_service {
        server command1:8004 max_fails=3 fail_timeout=30s;
        server command2:8004 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Firmware Service
    upstream firmware_service {
        server firmware1:8005 max_fails=3 fail_timeout=30s;
        server firmware2:8005 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # RATE LIMITING
    # =========================================================================
    limit_req_zone $binary_remote_addr zone=device:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=ingest:10m rate=100r/s;
    limit_req_zone $binary_remote_addr zone=analytics:10m rate=60r/m;
    limit_req_zone $binary_remote_addr zone=command:10m rate=10r/m;
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
    
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
        add_header X-XSS-Protection "1; mode=block" always;
        
        # IoT headers
        add_header X-IoT-Gateway "nginx" always;
        add_header X-IoT-Version "2.0.0" always;
        
        # =========================================================================
        # DEVICE REGISTRATION
        # =========================================================================
        location /device/register {
            # Strict rate limiting
            limit_req zone=device burst=1 nodelay;
            limit_conn conn_limit 1;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            proxy_pass http://device_service/device/register;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Device-ID $http_x_device_id;
            proxy_set_header X-Device-Type $http_x_device_type;
            proxy_set_header X-Device-Model $http_x_device_model;
            proxy_set_header X-Device-Version $http_x_device_version;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 10s;
            proxy_send_timeout 10s;
        }
        
        # =========================================================================
        # SENSOR DATA INGEST
        # =========================================================================
        location /ingest/ {
            # Device authentication
            auth_request /device/validate;
            
            # Rate limiting
            limit_req zone=ingest burst=20 nodelay;
            limit_conn conn_limit 20;
            
            # Disable buffering for high-throughput
            proxy_buffering off;
            proxy_request_buffering off;
            
            proxy_pass http://data_service/ingest/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Device-ID $http_x_device_id;
            proxy_set_header X-Sensor-Type $http_x_sensor_type;
            proxy_set_header X-Timestamp $http_x_timestamp;
            proxy_set_header X-Signature $http_x_signature;
            
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
        # EDGE ANALYTICS
        # =========================================================================
        location /analytics/ {
            auth_request /device/validate;
            
            # Rate limiting
            limit_req zone=analytics burst=10 nodelay;
            
            # Cache analytics results
            proxy_cache sensor_cache;
            proxy_cache_key $scheme$host$request_uri$http_x_device_id;
            proxy_cache_valid 200 5s;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://analytics_service/analytics/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Device-ID $http_x_device_id;
            proxy_set_header X-Analytic-Type $http_x_analytic_type;
            proxy_set_header X-Analytic-Window $http_x_analytic_window;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 10s;
            proxy_send_timeout 10s;
        }
        
        # =========================================================================
        # DEVICE COMMANDS
        # =========================================================================
        location /commands/ {
            auth_request /device/validate;
            
            # Rate limiting
            limit_req zone=command burst=2 nodelay;
            limit_conn conn_limit 2;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            proxy_pass http://command_service/commands/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Device-ID $http_x_device_id;
            proxy_set_header X-Command-ID $http_x_command_id;
            proxy_set_header X-Command-Type $http_x_command_type;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 10s;
            proxy_send_timeout 10s;
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
            proxy_cache device_cache;
            proxy_cache_key $scheme$host$request_uri$http_x_device_id;
            proxy_cache_valid 200 7d;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://firmware_service/firmware/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Device-ID $http_x_device_id;
            proxy_set_header X-Firmware-Version $http_x_firmware_version;
            
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
            
            proxy_pass http://device_service/validate;
            proxy_pass_request_body off;
            
            proxy_set_header Content-Length "";
            proxy_set_header X-Original-URI $request_uri;
            proxy_set_header X-Device-ID $http_x_device_id;
            proxy_set_header X-API-Key $http_x_api_key;
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
        # DEVICE STATE
        # =========================================================================
        location /device/state {
            auth_request /device/validate;
            
            # Cache device state
            proxy_cache device_cache;
            proxy_cache_key $scheme$host$request_uri$http_x_device_id;
            proxy_cache_valid 200 5s;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://device_service/device/state;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Device-ID $http_x_device_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 5s;
            proxy_send_timeout 5s;
        }
        
        # =========================================================================
        # IOT STATUS
        # =========================================================================
        location /iot/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "service_status":{
                    "device":$(curl -s -o /dev/null -w "%{http_code}" http://device1:8001/health),
                    "data":$(curl -s -o /dev/null -w "%{http_code}" http://data1:8002/health),
                    "analytics":$(curl -s -o /dev/null -w "%{http_code}" http://analytics1:8003/health),
                    "command":$(curl -s -o /dev/null -w "%{http_code}" http://command1:8004/health),
                    "firmware":$(curl -s -o /dev/null -w "%{http_code}" http://firmware1:8005/health)
                },
                "active_devices":$(tail -10000 /var/log/nginx/access.log | grep -o '"X-Device-ID":"[^"]*"' | cut -d'"' -f4 | sort -u | wc -l),
                "data_rate":$(tail -60 /var/log/nginx/access.log | grep -c "/ingest/"),
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

## P50.2 MQTT & CoAP Support

### MQTT over WebSocket Configuration

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
                "connected_clients":$(netstat -an | grep ':1883' | grep ESTABLISHED | wc -l),
                "ws_connections":$(netstat -an | grep ':443' | grep ESTABLISHED | grep -c "Upgrade"),
                "timestamp":"$time_iso8601"
            }';
            add_header Content-Type application/json;
        }
    }
}
```

## P50.3 IoT Monitoring Dashboard

### IoT Data Processing Dashboard

```bash
#!/bin/bash
# iot-processing-monitor.sh - IoT data processing monitoring

echo "=== IoT Data Processing Monitoring Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get device statistics
get_device_statistics() {
    local devices=$(tail -10000 /var/log/nginx/access.log | grep -o '"X-Device-ID":"[^"]*"' | cut -d'"' -f4 | sort -u | wc -l)
    local active=$(tail -1000 /var/log/nginx/access.log | grep -o '"X-Device-ID":"[^"]*"' | cut -d'"' -f4 | sort -u | wc -l)
    echo "  Device Statistics:"
    echo "    Total Devices: $devices"
    echo "    Active Devices: $active"
}

# Function: Get data ingestion rates
get_ingestion_rates() {
    local rate=$(tail -60 /var/log/nginx/access.log | grep -c "/ingest/")
    echo "  Data Ingestion Rate: $((rate / 1)) messages/min"
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

# Function: Get sensor types
get_sensor_types() {
    echo "  Sensor Types:"
    tail -10000 /var/log/nginx/access.log | \
        grep -o '"X-Sensor-Type":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | head -5 | \
        while read count type; do
            echo "    $type: $count"
        done
}

# Function: Get edge analytics
get_edge_analytics() {
    local analytics=$(tail -10000 /var/log/nginx/access.log | grep -c "/analytics/")
    local commands=$(tail -10000 /var/log/nginx/access.log | grep -c "/commands/")
    echo "  Edge Processing:"
    echo "    Analytics Requests: $analytics"
    echo "    Commands Sent: $commands"
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
    echo "║              IOT PROCESSING MONITORING DASHBOARD              ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 DEVICE STATISTICS:"
    get_device_statistics
    echo ""
    get_ingestion_rates
    echo ""
    get_device_types
    echo ""
    get_sensor_types
    echo ""
    get_edge_analytics
    echo ""
    get_error_rate
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx for IoT data processing and edge analytics. Use these techniques to build scalable, low-latency IoT platforms.
