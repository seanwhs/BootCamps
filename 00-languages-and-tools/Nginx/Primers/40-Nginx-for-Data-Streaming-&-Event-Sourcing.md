# Primer 40: Nginx for Data Streaming & Event Sourcing

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for data streaming and event sourcing architectures. Understanding these concepts is essential for building event-driven systems, data pipelines, and real-time analytics.

## P40.1 Data Streaming Architecture

### Streaming & Event Sourcing Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DATA STREAMING & EVENT SOURCING                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX STREAMING GATEWAY                        │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    EVENT STREAMING                        │ │      │
│  │  │  • Event Ingestion  • Stream Processing  • Windowing      │ │      │
│  │  │  • Aggregation      • Filtering          • Enrichment     │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    EVENT SOURCING                         │ │      │
│  │  │  • Event Store      • Snapshotting       • Replay         │ │      │
│  │  │  • Projections      • State Management   • CQRS          │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    REAL-TIME ANALYTICS                    │ │      │
│  │  │  • Event Analytics  • Dashboards        • Alerts          │ │      │
│  │  │  • Aggregations     • ML Predictions    • Anomaly Detection│ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    EVENT SOURCES                                  │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ Event      │  │ Event      │  │ Event      │  │ Event    │ │      │
│  │  │ Producer   │  │ Processor  │  │ Store      │  │ Consumer │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Data Streaming Configuration

```nginx
# nginx-data-streaming.conf - Complete Data Streaming
# ============================================================================
# NGINX DATA STREAMING & EVENT SOURCING
# Complete production-ready streaming configuration
# ============================================================================

http {
    # =========================================================================
    # STREAMING SETTINGS
    # =========================================================================
    # Large payloads for streaming
    client_max_body_size 50M;
    client_body_buffer_size 1M;
    client_header_buffer_size 4k;
    large_client_header_buffers 8 8k;
    
    # Streaming timeouts
    client_body_timeout 60s;
    client_header_timeout 60s;
    send_timeout 60s;
    keepalive_timeout 60;
    keepalive_requests 10000;
    
    # Proxy settings
    proxy_buffering off;
    proxy_request_buffering off;
    proxy_read_timeout 3600s;
    proxy_connect_timeout 75s;
    proxy_send_timeout 3600s;
    
    # =========================================================================
    # EVENT STORE
    # =========================================================================
    proxy_cache_path /var/cache/nginx/event_cache
        levels=1:2
        keys_zone=event_cache:500m
        max_size=10g
        inactive=1h
        use_temp_path=off;
    
    proxy_cache_path /var/cache/nginx/snapshot_cache
        levels=1:2
        keys_zone=snapshot_cache:200m
        max_size=5g
        inactive=30d
        use_temp_path=off;
    
    # =========================================================================
    # EVENT UPSTREAMS
    # =========================================================================
    # Event Ingest
    upstream event_ingest {
        least_conn;
        server ingest1:8001 max_fails=3 fail_timeout=30s;
        server ingest2:8001 max_fails=3 fail_timeout=30s;
        server ingest3:8001 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Event Processor
    upstream event_processor {
        least_conn;
        server processor1:8002 max_fails=3 fail_timeout=30s;
        server processor2:8002 max_fails=3 fail_timeout=30s;
        server processor3:8002 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Event Store
    upstream event_store {
        server store1:8003 max_fails=3 fail_timeout=30s;
        server store2:8003 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Event Projection
    upstream event_projection {
        server projection1:8004 max_fails=3 fail_timeout=30s;
        server projection2:8004 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Event Analytics
    upstream event_analytics {
        server analytics1:8005 max_fails=3 fail_timeout=30s;
        server analytics2:8005 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # RATE LIMITING
    # =========================================================================
    limit_req_zone $binary_remote_addr zone=event_ingest:10m rate=100r/s;
    limit_req_zone $binary_remote_addr zone=event_query:10m rate=10r/s;
    limit_conn_zone $binary_remote_addr zone=event_conn:10m;
    
    # =========================================================================
    # MAIN STREAMING SERVER
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
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1h;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        
        # Streaming headers
        add_header X-Stream-Gateway "nginx" always;
        add_header X-Stream-Version "2.0.0" always;
        
        # =========================================================================
        # EVENT INGESTION
        # =========================================================================
        location /events/ingest {
            # Rate limiting
            limit_req zone=event_ingest burst=50 nodelay;
            limit_conn event_conn 20;
            
            # Event validation
            if ($content_type !~ "application/json") {
                return 415 '{"error":"Content-Type must be application/json"}';
                add_header Content-Type application/json;
            }
            
            # Disable buffering for speed
            proxy_buffering off;
            proxy_request_buffering off;
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Event-ID $http_x_event_id;
            proxy_set_header X-Event-Type $http_x_event_type;
            proxy_set_header X-Event-Source $http_x_event_source;
            proxy_set_header X-Event-Timestamp $http_x_event_timestamp;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Short timeouts for ingestion
            proxy_connect_timeout 2s;
            proxy_read_timeout 5s;
            proxy_send_timeout 5s;
            
            # Retry on failure
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
            proxy_next_upstream_tries 2;
            
            proxy_pass http://event_ingest;
        }
        
        # =========================================================================
        # EVENT STORE
        # =========================================================================
        location /events/store {
            # Event storage
            proxy_pass http://event_store;
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
        # EVENT PROJECTIONS
        # =========================================================================
        location /events/projections {
            # Event projections (CQRS read models)
            proxy_pass http://event_projection;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Projection-Name $http_x_projection_name;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Cache projections
            proxy_cache snapshot_cache;
            proxy_cache_key $scheme$host$request_uri$http_x_projection_name;
            proxy_cache_valid 200 10m;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # EVENT REPLAY
        # =========================================================================
        location /events/replay {
            # Event replay for debugging/recovery
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            proxy_pass http://event_store/replay;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Event-Type $http_x_event_type;
            proxy_set_header X-From-Timestamp $http_x_from_timestamp;
            proxy_set_header X-To-Timestamp $http_x_to_timestamp;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_read_timeout 300s;
            proxy_connect_timeout 30s;
            proxy_send_timeout 300s;
        }
        
        # =========================================================================
        # EVENT SNAPSHOTS
        # =========================================================================
        location /events/snapshots {
            # Event snapshots for state recovery
            proxy_pass http://event_store/snapshots;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Aggregate-ID $http_x_aggregate_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Cache snapshots
            proxy_cache snapshot_cache;
            proxy_cache_key $scheme$host$request_uri$http_x_aggregate_id;
            proxy_cache_valid 200 30d;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # REAL-TIME ANALYTICS
        # =========================================================================
        location /analytics/events {
            # Real-time event analytics
            proxy_pass http://event_analytics;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Analytic-Type $http_x_analytic_type;
            proxy_set_header X-Analytic-Window $http_x_analytic_window;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Disable caching for real-time
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # EVENT ANALYTICS (AD-HOC QUERIES)
        # =========================================================================
        location /analytics/query {
            # Ad-hoc event queries
            limit_req zone=event_query burst=10 nodelay;
            
            proxy_pass http://event_analytics/query;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Query-SQL $http_x_query_sql;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 10s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
        }
        
        # =========================================================================
        # STREAMING STATUS
        # =========================================================================
        location /streaming/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "events_ingested":$(tail -10000 /var/log/nginx/access.log | grep -c "/events/ingest"),
                "events_stored":$(tail -10000 /var/log/nginx/access.log | grep -c "/events/store"),
                "projections":$(tail -10000 /var/log/nginx/access.log | grep -c "/events/projections"),
                "snapshots":$(tail -10000 /var/log/nginx/access.log | grep -c "/events/snapshots"),
                "analytics_queries":$(tail -10000 /var/log/nginx/access.log | grep -c "/analytics/"),
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

## P40.2 Event Sourcing with Lua

### Event Sourcing Handler

```lua
-- event-sourcing.lua - Event Sourcing Handler
-- ============================================================================
-- EVENT SOURCING HANDLER
-- Complete event sourcing implementation
-- ============================================================================

local event_sourcing = {}

-- Event store
event_sourcing.events = {}
event_sourcing.snapshots = {}

-- Event types
event_sourcing.EVENT_TYPES = {
    USER_CREATED = "user_created",
    USER_UPDATED = "user_updated",
    USER_DELETED = "user_deleted",
    ORDER_CREATED = "order_created",
    ORDER_UPDATED = "order_updated",
    ORDER_CANCELLED = "order_cancelled",
    PAYMENT_PROCESSED = "payment_processed",
    PAYMENT_FAILED = "payment_failed"
}

-- =========================================================================
-- EVENT STORE OPERATIONS
-- =========================================================================

-- Store event
function event_sourcing.store_event(event)
    -- Validate event
    if not event.type or not event.aggregate_id then
        return nil, "Invalid event: missing type or aggregate_id"
    end
    
    -- Generate event ID
    event.id = event.id or ngx.var.request_id or string.gsub(ngx.md5(ngx.var.request_id), "-", "")
    event.timestamp = event.timestamp or os.time()
    event.version = event.version or 1
    
    -- Store event
    local key = event.aggregate_id .. ":" .. event.type
    if not event_sourcing.events[key] then
        event_sourcing.events[key] = {}
    end
    
    table.insert(event_sourcing.events[key], event)
    
    -- Store globally
    event_sourcing.events["all"] = event_sourcing.events["all"] or {}
    table.insert(event_sourcing.events["all"], event)
    
    return event
end

-- Get events for aggregate
function event_sourcing.get_events(aggregate_id, event_type)
    local key = aggregate_id
    if event_type then
        key = key .. ":" .. event_type
    end
    
    return event_sourcing.events[key] or {}
end

-- Get all events
function event_sourcing.get_all_events()
    return event_sourcing.events["all"] or {}
end

-- =========================================================================
-- SNAPSHOT OPERATIONS
-- =========================================================================

-- Create snapshot
function event_sourcing.create_snapshot(aggregate_id, state)
    event_sourcing.snapshots[aggregate_id] = {
        state = state,
        timestamp = os.time(),
        version = state.version or 1
    }
    return event_sourcing.snapshots[aggregate_id]
end

-- Get snapshot
function event_sourcing.get_snapshot(aggregate_id)
    return event_sourcing.snapshots[aggregate_id]
end

-- =========================================================================
-- AGGREGATE OPERATIONS
-- =========================================================================

-- Rebuild aggregate from events
function event_sourcing.rebuild_aggregate(aggregate_id, event_type)
    local events = event_sourcing.get_events(aggregate_id, event_type)
    local state = {
        id = aggregate_id,
        version = 0,
        created_at = nil,
        updated_at = nil
    }
    
    for _, event in ipairs(events) do
        if event.type == event_sourcing.EVENT_TYPES.USER_CREATED then
            state.name = event.data.name
            state.email = event.data.email
            state.role = event.data.role
            state.created_at = event.timestamp
        elseif event.type == event_sourcing.EVENT_TYPES.USER_UPDATED then
            state.name = event.data.name or state.name
            state.email = event.data.email or state.email
            state.role = event.data.role or state.role
            state.updated_at = event.timestamp
        elseif event.type == event_sourcing.EVENT_TYPES.USER_DELETED then
            state.deleted_at = event.timestamp
            state.deleted = true
        end
    end
    
    state.version = #events
    
    return state
end

-- Apply command
function event_sourcing.apply_command(aggregate_id, command)
    local state = event_sourcing.get_snapshot(aggregate_id)
    if not state then
        state = event_sourcing.rebuild_aggregate(aggregate_id)
    end
    
    -- Process command
    local event = {
        aggregate_id = aggregate_id,
        type = command.type,
        data = command.data,
        timestamp = os.time(),
        command_id = command.id or ngx.var.request_id
    }
    
    -- Store event
    local stored_event = event_sourcing.store_event(event)
    if not stored_event then
        return nil, "Failed to store event"
    end
    
    -- Update snapshot (every 10 events)
    if #event_sourcing.get_events(aggregate_id) % 10 == 0 then
        local new_state = event_sourcing.rebuild_aggregate(aggregate_id)
        event_sourcing.create_snapshot(aggregate_id, new_state)
    end
    
    return stored_event
end

-- =========================================================================
-- QUERY HANDLERS
-- =========================================================================

-- Get aggregate state
function event_sourcing.get_aggregate_state(aggregate_id)
    local snapshot = event_sourcing.get_snapshot(aggregate_id)
    if snapshot then
        return snapshot.state
    end
    
    return event_sourcing.rebuild_aggregate(aggregate_id)
end

-- Get event projection
function event_sourcing.get_projection(projection_name, aggregate_id)
    local events = event_sourcing.get_events(aggregate_id)
    local projection = {}
    
    for _, event in ipairs(events) do
        if projection_name == "user" then
            if event.type == event_sourcing.EVENT_TYPES.USER_CREATED then
                projection[event.aggregate_id] = {
                    name = event.data.name,
                    email = event.data.email,
                    role = event.data.role,
                    created_at = event.timestamp
                }
            elseif event.type == event_sourcing.EVENT_TYPES.USER_UPDATED then
                if projection[event.aggregate_id] then
                    projection[event.aggregate_id].name = event.data.name or projection[event.aggregate_id].name
                    projection[event.aggregate_id].email = event.data.email or projection[event.aggregate_id].email
                    projection[event.aggregate_id].role = event.data.role or projection[event.aggregate_id].role
                end
            elseif event.type == event_sourcing.EVENT_TYPES.USER_DELETED then
                projection[event.aggregate_id] = nil
            end
        elseif projection_name == "order" then
            -- Order projection logic
        end
    end
    
    return projection
end

-- =========================================================================
-- HTTP HANDLERS
-- =========================================================================

-- Store event handler
function event_sourcing.handle_store_event()
    -- Read request body
    ngx.req.read_body()
    local body = ngx.req.get_body_data()
    
    if not body then
        ngx.status = 400
        ngx.say('{"error":"Missing event data"}')
        return
    end
    
    -- Parse JSON
    local json = require("cjson")
    local event = json.decode(body)
    
    if not event then
        ngx.status = 400
        ngx.say('{"error":"Invalid JSON"}')
        return
    end
    
    -- Store event
    local stored_event, err = event_sourcing.store_event(event)
    if not stored_event then
        ngx.status = 400
        ngx.say('{"error":"' .. err .. '"}')
        return
    end
    
    ngx.status = 201
    ngx.say(json.encode(stored_event))
end

-- Get events handler
function event_sourcing.handle_get_events()
    local aggregate_id = ngx.var.arg_aggregate_id
    local event_type = ngx.var.arg_event_type
    
    if not aggregate_id then
        ngx.status = 400
        ngx.say('{"error":"aggregate_id required"}')
        return
    end
    
    local events = event_sourcing.get_events(aggregate_id, event_type)
    local json = require("cjson")
    
    ngx.status = 200
    ngx.say(json.encode(events))
end

-- Rebuild aggregate handler
function event_sourcing.handle_rebuild_aggregate()
    local aggregate_id = ngx.var.arg_aggregate_id
    local event_type = ngx.var.arg_event_type
    
    if not aggregate_id then
        ngx.status = 400
        ngx.say('{"error":"aggregate_id required"}')
        return
    end
    
    local state = event_sourcing.rebuild_aggregate(aggregate_id, event_type)
    local json = require("cjson")
    
    ngx.status = 200
    ngx.say(json.encode(state))
end

-- Apply command handler
function event_sourcing.handle_apply_command()
    ngx.req.read_body()
    local body = ngx.req.get_body_data()
    
    if not body then
        ngx.status = 400
        ngx.say('{"error":"Missing command data"}')
        return
    end
    
    local json = require("cjson")
    local command = json.decode(body)
    
    if not command or not command.aggregate_id or not command.type then
        ngx.status = 400
        ngx.say('{"error":"Invalid command: missing aggregate_id or type"}')
        return
    end
    
    local stored_event, err = event_sourcing.apply_command(command.aggregate_id, command)
    if not stored_event then
        ngx.status = 400
        ngx.say('{"error":"' .. err .. '"}')
        return
    end
    
    ngx.status = 200
    ngx.say(json.encode(stored_event))
end

-- Register handlers
return event_sourcing
```

## P40.3 Data Streaming Monitoring

### Streaming Monitoring Dashboard

```bash
#!/bin/bash
# streaming-monitor.sh - Data streaming monitoring

echo "=== Data Streaming Monitoring Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get event rates
get_event_rates() {
    local ingest=$(tail -60 /var/log/nginx/access.log | grep -c "/events/ingest")
    local store=$(tail -60 /var/log/nginx/access.log | grep -c "/events/store")
    local projections=$(tail -60 /var/log/nginx/access.log | grep -c "/events/projections")
    
    echo "  Event Rates:"
    echo "    Ingestion: $((ingest / 1)) events/min"
    echo "    Storage: $((store / 1)) events/min"
    echo "    Projections: $((projections / 1)) events/min"
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

# Function: Get aggregate stats
get_aggregate_stats() {
    local aggregates=$(tail -10000 /var/log/nginx/access.log | \
        grep -o '"X-Aggregate-ID":"[^"]*"' | \
        cut -d'"' -f4 | sort -u | wc -l)
    echo "  Active Aggregates: $aggregates"
}

# Function: Get snapshot stats
get_snapshot_stats() {
    local snapshots=$(tail -10000 /var/log/nginx/access.log | grep -c "/events/snapshots")
    echo "  Snapshots Created: $snapshots"
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
    echo "║              DATA STREAMING MONITORING DASHBOARD              ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 EVENT STATISTICS:"
    get_event_rates
    echo ""
    get_event_types
    echo ""
    get_aggregate_stats
    get_snapshot_stats
    echo ""
    get_error_rate
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx for data streaming and event sourcing architectures. Use these techniques to build event-driven systems, data pipelines, and real-time analytics applications.
