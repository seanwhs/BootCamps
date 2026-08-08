# Primer 28: Nginx for Event-Driven Architecture

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for event-driven architectures, event streaming, and asynchronous communication patterns. Understanding these concepts is essential for building modern, event-driven systems at scale.

## P28.1 Event-Driven Architecture Overview

### Event-Driven System Architecture

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    EVENT-DRIVEN ARCHITECTURE                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX EVENT GATEWAY                            │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    EVENT ROUTING                          │ │      │
│  │  │  • Event Patterns   • Event Routing   • Event Filtering   │ │      │
│  │  │  • Event Transform  • Event Enrichment • Event Correlation│ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    EVENT STREAMING                        │ │      │
│  │  │  • Event Ingestion  • Stream Processing  • Fan-Out       │ │      │
│  │  │  • WebHooks        • Callbacks          • Async Replies  │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    EVENT PERSISTENCE                      │ │      │
│  │  │  • Event Store     • Event Sourcing     • Snapshots       │ │      │
│  │  │  • CQRS            • Materialized Views • Replay         │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    EVENT BUS / BROKER                            │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ Kafka      │  │ RabbitMQ   │  │ NATS       │  │  Pulsar   │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐           │
│  │              │              │              │              │           │
│  ▼              ▼              ▼              ▼              ▼           │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐           │
│  │ Event  │  │ Event  │  │ Event  │  │ Event  │  │ Event  │           │
│  │Producer│  │Consumer│  │Handler │  │Store   │  │Router  │           │
│  └────────┘  └────────┘  └────────┘  └────────┘  └────────┘           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Event-Driven Configuration

```nginx
# nginx-event-driven.conf - Complete Event-Driven Configuration
# ============================================================================
# NGINX EVENT-DRIVEN GATEWAY
# Complete production-ready event-driven configuration
# ============================================================================

http {
    # =========================================================================
    # EVENT RATE LIMITING
    # =========================================================================
    limit_req_zone $binary_remote_addr zone=event_ingest:10m rate=100r/s;
    limit_req_zone $binary_remote_addr zone=event_webhook:10m rate=10r/s;
    limit_conn_zone $binary_remote_addr zone=event_conn:10m;
    
    # =========================================================================
    # EVENT CACHING
    # =========================================================================
    proxy_cache_path /var/cache/nginx/event_cache
        levels=1:2
        keys_zone=event_cache:200m
        max_size=5g
        inactive=1h
        use_temp_path=off;
    
    # =========================================================================
    # EVENT UPSTREAMS
    # =========================================================================
    # Event Ingestion
    upstream event_ingest {
        least_conn;
        server ingest1:8000 max_fails=3 fail_timeout=30s;
        server ingest2:8000 max_fails=3 fail_timeout=30s;
        server ingest3:8000 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Event Processing
    upstream event_processor {
        least_conn;
        server processor1:8001 max_fails=3 fail_timeout=30s;
        server processor2:8001 max_fails=3 fail_timeout=30s;
        server processor3:8001 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Event Webhooks
    upstream event_webhooks {
        server webhook1:8002 max_fails=3 fail_timeout=30s;
        server webhook2:8002 max_fails=3 fail_timeout=30s;
        server webhook3:8002 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Event Store
    upstream event_store {
        server store1:8003 max_fails=3 fail_timeout=30s;
        server store2:8003 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # EVENT SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name events.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/events.crt;
        ssl_certificate_key /etc/nginx/ssl/events.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        
        # =========================================================================
        # EVENT INGESTION
        # =========================================================================
        location /events/ingest {
            # Rate limiting for event ingestion
            limit_req zone=event_ingest burst=50 nodelay;
            limit_conn event_conn 20;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            # Disable buffering for speed
            proxy_buffering off;
            proxy_request_buffering off;
            
            proxy_pass http://event_ingest/events/ingest;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Event-ID $http_x_event_id;
            proxy_set_header X-Event-Type $http_x_event_type;
            proxy_set_header X-Source $http_x_source;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Short timeouts for ingestion
            proxy_connect_timeout 2s;
            proxy_read_timeout 5s;
            proxy_send_timeout 5s;
            
            # Retry on failure
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
            proxy_next_upstream_tries 2;
        }
        
        # =========================================================================
        # EVENT PROCESSING
        # =========================================================================
        location /events/process {
            # Event processing endpoint
            proxy_pass http://event_processor/events/process;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Event-ID $http_x_event_id;
            proxy_set_header X-Event-Type $http_x_event_type;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Timeouts for processing
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # EVENT WEBHOOKS
        # =========================================================================
        location /events/webhook {
            # Rate limiting for webhooks
            limit_req zone=event_webhook burst=5 nodelay;
            limit_conn event_conn 5;
            
            # Webhook specific settings
            client_max_body_size 10M;
            client_body_buffer_size 128k;
            
            proxy_pass http://event_webhooks/events/webhook;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Event-ID $http_x_event_id;
            proxy_set_header X-Event-Type $http_x_event_type;
            proxy_set_header X-Webhook-ID $http_x_webhook_id;
            proxy_set_header X-Webhook-Secret $http_x_webhook_secret;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Buffer for large payloads
            proxy_buffering on;
            proxy_buffer_size 128k;
            proxy_buffers 4 256k;
            proxy_busy_buffers_size 256k;
            
            # Webhook timeouts
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
            
            # Retry on failure
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
            proxy_next_upstream_tries 3;
            proxy_next_upstream_timeout 30s;
        }
        
        # =========================================================================
        # EVENT STORE
        # =========================================================================
        location /events/store {
            # Event store operations
            proxy_pass http://event_store/events/store;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Event-ID $http_x_event_id;
            proxy_set_header X-Event-Type $http_x_event_type;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Cache for event queries
            proxy_cache event_cache;
            proxy_cache_key $scheme$host$request_uri$http_x_event_type;
            proxy_cache_valid 200 5m;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 10s;
            proxy_send_timeout 10s;
        }
        
        # =========================================================================
        # EVENT STREAMS
        # =========================================================================
        location /events/streams {
            # Event stream subscription
            proxy_pass http://event_processor/events/streams;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Event-Type $http_x_event_type;
            proxy_set_header X-Stream-ID $http_x_stream_id;
            
            # Streaming settings
            proxy_buffering off;
            proxy_cache off;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            add_header X-Accel-Buffering "no";
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Long timeouts for streaming
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
        }
        
        # =========================================================================
        # EVENT REPLAY
        # =========================================================================
        location /events/replay {
            # Event replay for debugging
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            proxy_pass http://event_store/events/replay;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_read_timeout 300s;
        }
        
        # =========================================================================
        # EVENT STATUS
        # =========================================================================
        location /events/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "events_ingested":$(tail -10000 /var/log/nginx/access.log | grep -c "/events/ingest"),
                "events_processed":$(tail -10000 /var/log/nginx/access.log | grep -c "/events/process"),
                "events_webhooks":$(tail -10000 /var/log/nginx/access.log | grep -c "/events/webhook"),
                "active_streams":$(netstat -an | grep ':443' | grep ESTABLISHED | wc -l),
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

## P28.2 Event Webhook Implementation

### Webhook Management Configuration

```nginx
# nginx-webhooks.conf - Webhook Management
# ============================================================================
# NGINX WEBHOOK MANAGEMENT
# Complete webhook delivery configuration
# ============================================================================

http {
    # =========================================================================
    # WEBHOOK UPSTREAMS
    # =========================================================================
    upstream webhook_delivery {
        server delivery1:8000 max_fails=3 fail_timeout=30s;
        server delivery2:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    upstream webhook_retry {
        server retry1:8001 max_fails=3 fail_timeout=30s;
        server retry2:8001 max_fails=3 fail_timeout=30s;
        keepalive 16;
    }
    
    # =========================================================================
    # WEBHOOK SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        server_name webhooks.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/webhooks.crt;
        ssl_certificate_key /etc/nginx/ssl/webhooks.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        
        # =========================================================================
        # WEBHOOK DELIVERY
        # =========================================================================
        location /deliver {
            # Webhook delivery endpoint
            proxy_pass http://webhook_delivery/deliver;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Webhook-ID $http_x_webhook_id;
            proxy_set_header X-Webhook-URL $http_x_webhook_url;
            proxy_set_header X-Webhook-Secret $http_x_webhook_secret;
            proxy_set_header X-Event-ID $http_x_event_id;
            proxy_set_header X-Event-Type $http_x_event_type;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Webhook delivery timeouts
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
            
            # Retry on failure
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
            proxy_next_upstream_tries 3;
            
            # Buffering
            proxy_buffering on;
            proxy_buffer_size 16k;
            proxy_buffers 8 16k;
            proxy_busy_buffers_size 32k;
        }
        
        # =========================================================================
        # WEBHOOK RETRY
        # =========================================================================
        location /retry {
            # Webhook retry endpoint
            proxy_pass http://webhook_retry/retry;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Webhook-ID $http_x_webhook_id;
            proxy_set_header X-Retry-Count $http_x_retry_count;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Retry timeouts
            proxy_connect_timeout 10s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
            
            # Exponential backoff
            set $retry_delay 60;
            if ($http_x_retry_count = "1") {
                set $retry_delay 30;
            }
            if ($http_x_retry_count = "2") {
                set $retry_delay 60;
            }
            if ($http_x_retry_count = "3") {
                set $retry_delay 120;
            }
            if ($http_x_retry_count = "4") {
                set $retry_delay 300;
            }
            
            add_header Retry-After $retry_delay;
        }
        
        # =========================================================================
        # WEBHOOK STATUS
        # =========================================================================
        location /webhooks/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "deliveries":$(tail -10000 /var/log/nginx/access.log | grep -c "/deliver"),
                "retries":$(tail -10000 /var/log/nginx/access.log | grep -c "/retry"),
                "success_rate":$(( $(tail -1000 /var/log/nginx/access.log | grep "/deliver" | grep -c '"status":200') * 100 / $(tail -1000 /var/log/nginx/access.log | grep -c "/deliver") )),
                "timestamp":"$time_iso8601"
            }';
            add_header Content-Type application/json;
        }
    }
}
```

## P28.3 Event Stream Processing

### Stream Processing with Lua

```lua
-- event-stream.lua - Event Stream Processing
-- ============================================================================
-- LUA EVENT STREAM PROCESSING
-- Real-time event stream processing at the edge
-- ============================================================================

local event_stream = {}

-- Event processors
event_stream.processors = {
    filter_events = function(event)
        -- Filter out unwanted events
        if event.type == "heartbeat" then
            return false
        end
        if event.type == "ping" and event.data.count > 100 then
            return false
        end
        return true
    end,
    
    transform_event = function(event)
        -- Transform event data
        local transformed = {
            id = event.id,
            type = event.type,
            timestamp = event.timestamp,
            source = event.source,
            data = event.data
        }
        
        -- Add processing metadata
        transformed.processed_at = os.time()
        transformed.processor = "nginx-edge"
        
        return transformed
    end,
    
    enrich_event = function(event)
        -- Enrich with context
        event.enrichment = {
            geoip = ngx.var.geoip_country_code,
            user_agent = ngx.var.http_user_agent,
            request_id = ngx.var.request_id
        }
        return event
    end
}

-- Stream handler
function event_stream.handle_stream()
    -- Read event batch
    ngx.req.read_body()
    local body = ngx.req.get_body_data()
    
    if not body then
        ngx.status = 400
        ngx.say('{"error":"Missing event data"}')
        return
    end
    
    -- Parse JSON
    local json = require("cjson")
    local events = json.decode(body)
    
    if not events then
        ngx.status = 400
        ngx.say('{"error":"Invalid JSON"}')
        return
    end
    
    -- Ensure events is an array
    if type(events) ~= "table" then
        events = {events}
    end
    
    -- Process each event
    local processed_events = {}
    local processed_count = 0
    
    for _, event in ipairs(events) do
        -- Validate event
        if not event.type or not event.data then
            ngx.log(ngx.WARN, "Invalid event: missing type or data")
            goto continue
        end
        
        -- Filter
        if not event_stream.processors.filter_events(event) then
            goto continue
        end
        
        -- Transform
        local processed = event_stream.processors.transform_event(event)
        
        -- Enrich
        processed = event_stream.processors.enrich_event(processed)
        
        -- Add to result
        table.insert(processed_events, processed)
        processed_count = processed_count + 1
        
        ::continue::
    end
    
    -- Prepare response
    local response = {
        processed = processed_count,
        events = processed_events,
        timestamp = os.time()
    }
    
    -- Add response headers
    ngx.header["X-Processed-Count"] = processed_count
    ngx.header["X-Content-Type-Options"] = "nosniff"
    
    -- Return response
    ngx.status = 200
    ngx.say(json.encode(response))
end

-- Register handler
return event_stream
```

## P28.4 Event Monitoring Dashboard

### Event System Monitoring

```bash
#!/bin/bash
# event-monitor.sh - Event system monitoring

echo "=== Event System Monitoring ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get event ingestion rate
get_ingestion_rate() {
    local events=$(tail -60 /var/log/nginx/access.log | grep -c "/events/ingest")
    echo "  Ingestion Rate: $((events / 1)) events/min"
}

# Function: Get webhook delivery rate
get_webhook_rate() {
    local webhooks=$(tail -60 /var/log/nginx/access.log | grep -c "/events/webhook")
    echo "  Webhook Rate: $((webhooks / 1)) webhooks/min"
}

# Function: Get event types
get_event_types() {
    echo "  Event Types:"
    tail -10000 /var/log/nginx/access.log | \
        grep -o '"X-Event-Type":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | head -5 | \
        while read count type; do
            echo "    $type: $count"
        done
}

# Function: Get active streams
get_active_streams() {
    local streams=$(netstat -an | grep ':443' | grep ESTABLISHED | wc -l)
    echo "  Active Streams: $streams"
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
    echo "║              EVENT SYSTEM MONITORING DASHBOARD                ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 EVENT METRICS:"
    get_ingestion_rate
    get_webhook_rate
    get_active_streams
    get_error_rate
    echo ""
    
    echo "📈 EVENT TYPES:"
    get_event_types
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx for event-driven architectures, event streaming, and asynchronous communication patterns. Use these techniques to build modern, event-driven systems at scale.
