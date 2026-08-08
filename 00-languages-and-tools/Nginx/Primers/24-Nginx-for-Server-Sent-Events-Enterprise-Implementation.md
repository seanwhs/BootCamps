# Primer 24: Nginx for Server-Sent Events (SSE) - Enterprise Implementation

## The Target

This primer provides a comprehensive, enterprise-grade deep-dive guide to implementing Server-Sent Events (SSE) with Nginx. Understanding these concepts is essential for building real-time, event-driven applications at scale.

## P24.1 SSE Architecture

### Enterprise SSE Architecture

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ENTERPRISE SSE ARCHITECTURE                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX SSE GATEWAY                              │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    CONNECTION MANAGEMENT                   │ │      │
│  │  │  • Keep-Alive         • Reconnection      • Heartbeat     │ │      │
│  │  │  • Load Balancing     • Failover          • Throttling    │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    EVENT PROCESSING                       │ │      │
│  │  │  • Filtering         • Transformation    • Aggregation    │ │      │
│  │  │  • Routing           • Batching          • Compression    │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    DELIVERY OPTIMIZATION                  │ │      │
│  │  │  • Buffering Control  • Chunked Transfer  • Gzip         │ │      │
│  │  │  • Cache Control      • ETag             • Last-Modified │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    SSE BACKEND SERVICES                         │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ Event      │  │ Event      │  │ Event      │  │ Event    │ │      │
│  │  │ Producer   │  │ Processor  │  │ Router     │  │ Store    │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete SSE Implementation

```nginx
# nginx-sse.conf - Complete SSE Implementation
# ============================================================================
# NGINX SERVER-SENT EVENTS - ENTERPRISE IMPLEMENTATION
# Complete production-ready SSE configuration
# ============================================================================

http {
    # =========================================================================
    # PERFORMANCE SETTINGS
    # =========================================================================
    worker_processes auto;
    worker_rlimit_nofile 65535;
    
    events {
        worker_connections 65535;
        use epoll;
        multi_accept on;
        accept_mutex off;
    }
    
    # =========================================================================
    # BASIC SETTINGS
    # =========================================================================
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    server_tokens off;
    charset utf-8;
    
    # =========================================================================
    # SSE SPECIFIC SETTINGS
    # =========================================================================
    # Disable buffering for SSE
    proxy_buffering off;
    proxy_request_buffering off;
    
    # Long timeouts for persistent connections
    proxy_read_timeout 3600s;
    proxy_connect_timeout 75s;
    proxy_send_timeout 3600s;
    
    # Connection management
    keepalive_timeout 3600s;
    keepalive_requests 10000;
    
    # Buffer sizes
    client_header_buffer_size 4k;
    large_client_header_buffers 8 8k;
    
    # =========================================================================
    # SSE SPECIFIC HEADERS
    # =========================================================================
    map $http_accept $sse_content_type {
        default "text/event-stream";
        "~*text/event-stream" "text/event-stream";
    }
    
    map $http_cache_control $sse_cache_control {
        default "no-cache, no-store, must-revalidate";
        "no-cache" "no-cache, no-store, must-revalidate";
    }
    
    # =========================================================================
    # SSE UPSTREAMS
    # =========================================================================
    # Event producers
    upstream event_producers {
        server producer1:8000 max_fails=3 fail_timeout=30s;
        server producer2:8000 max_fails=3 fail_timeout=30s;
        server producer3:8000 max_fails=3 fail_timeout=30s;
        keepalive 128;
        keepalive_requests 10000;
    }
    
    # Event processors
    upstream event_processors {
        least_conn;
        server processor1:8001 max_fails=3 fail_timeout=30s;
        server processor2:8001 max_fails=3 fail_timeout=30s;
        server processor3:8001 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Event routers (for fanout)
    upstream event_routers {
        server router1:8002 max_fails=3 fail_timeout=30s;
        server router2:8002 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # SSE CACHE
    # =========================================================================
    proxy_cache_path /var/cache/nginx/sse_cache
        levels=1:2
        keys_zone=sse_cache:100m
        max_size=1g
        inactive=1h
        use_temp_path=off;
    
    # =========================================================================
    # MAIN SSE SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name sse.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/sse.crt;
        ssl_certificate_key /etc/nginx/ssl/sse.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1h;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        
        # CORS for SSE
        add_header Access-Control-Allow-Origin "*" always;
        add_header Access-Control-Allow-Methods "GET, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Authorization, Content-Type, Accept, Cache-Control" always;
        add_header Access-Control-Expose-Headers "X-Event-ID, X-Event-Count" always;
        
        # =========================================================================
        # SSE ENDPOINT
        # =========================================================================
        location /events {
            # SSE specific headers
            add_header Content-Type $sse_content_type always;
            add_header Cache-Control $sse_cache_control always;
            add_header X-Accel-Buffering "no" always;
            add_header Connection "keep-alive" always;
            
            # Disable all buffering
            proxy_buffering off;
            proxy_request_buffering off;
            proxy_cache off;
            proxy_cache_bypass 1;
            proxy_no_cache 1;
            
            # Enable chunked transfer encoding
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Set SSE specific headers
            proxy_set_header Accept "text/event-stream";
            proxy_set_header Cache-Control "no-cache";
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $cookie_user_id;
            proxy_set_header X-Session-ID $cookie_session_id;
            
            # Event routing based on query parameters
            if ($arg_stream) {
                set $stream_name $arg_stream;
                proxy_pass http://event_routers/events/stream/$stream_name;
                break;
            }
            
            # Default event producer
            proxy_pass http://event_producers/events;
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Timeouts
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
            
            # Retry on failure
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
            proxy_next_upstream_tries 3;
            
            # Access log with SSE specific format
            access_log /var/log/nginx/sse.log sse;
        }
        
        # =========================================================================
        # SSE HEARTBEAT ENDPOINT
        # =========================================================================
        location /heartbeat {
            # Send periodic heartbeat
            add_header Content-Type "text/event-stream";
            add_header Cache-Control "no-cache";
            
            # Return SSE heartbeat
            return 200 'data: heartbeat\n\n';
        }
        
        # =========================================================================
        # SSE EVENT STREAM (PROCESSED)
        # =========================================================================
        location /streams/ {
            # Processed event streams
            proxy_pass http://event_processors/streams/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $cookie_user_id;
            
            # SSE specific settings
            proxy_buffering off;
            proxy_cache off;
            add_header Content-Type "text/event-stream";
            add_header Cache-Control "no-cache";
            add_header X-Accel-Buffering "no";
            
            proxy_read_timeout 3600s;
        }
        
        # =========================================================================
        # SSE EVENT REPLAY
        # =========================================================================
        location /replay/ {
            # Replay historical events
            proxy_pass http://event_store/replay/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $cookie_user_id;
            
            # Cache for replay
            proxy_cache sse_cache;
            proxy_cache_key $scheme$host$request_uri$arg_from$arg_to;
            proxy_cache_valid 200 10m;
            add_header X-Cache-Status $upstream_cache_status;
            
            # SSE settings
            proxy_buffering off;
            add_header Content-Type "text/event-stream";
            add_header Cache-Control "no-cache";
            
            proxy_read_timeout 300s;
        }
        
        # =========================================================================
        # SSE ADMIN ENDPOINTS
        # =========================================================================
        location /admin/sse-status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "active_connections":$(netstat -an | grep ':443' | grep ESTABLISHED | wc -l),
                "event_rate":$(tail -1000 /var/log/nginx/sse.log | grep -c '"event":'),
                "cache_hits":$(tail -1000 /var/log/nginx/sse.log | grep -c '"cache_status":"HIT"'),
                "timestamp":"$time_iso8601"
            }';
            add_header Content-Type application/json;
        }
        
        # =========================================================================
        # SSE METRICS (PROMETHEUS)
        # =========================================================================
        location /metrics {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            stub_status on;
            access_log off;
        }
        
        # =========================================================================
        # HEALTH CHECK
        # =========================================================================
        location /health {
            access_log off;
            return 200 "healthy\n";
        }
    }
    
    # =========================================================================
    # SSE LOG FORMAT
    # =========================================================================
    log_format sse escape=json '{'
        '"timestamp":"$time_iso8601",'
        '"request_id":"$request_id",'
        '"remote_addr":"$remote_addr",'
        '"user_id":"$cookie_user_id",'
        '"session_id":"$cookie_session_id",'
        '"event_stream":"$arg_stream",'
        '"bytes_sent":$bytes_sent,'
        '"request_time":$request_time,'
        '"upstream_addr":"$upstream_addr",'
        '"upstream_response_time":$upstream_response_time,'
        '"cache_status":"$upstream_cache_status"'
    '}';
}
```

## P24.2 SSE Client Management

### SSE Client Library

```javascript
// sse-client.js - Enterprise SSE Client
// ============================================================================
// SSE CLIENT LIBRARY
// Production-ready SSE client with enterprise features
// ============================================================================

class SSEConnection {
    constructor(options = {}) {
        this.url = options.url || '/events';
        this.reconnectDelay = options.reconnectDelay || 3000;
        this.maxReconnectAttempts = options.maxReconnectAttempts || 10;
        this.timeout = options.timeout || 30000;
        this.heartbeatInterval = options.heartbeatInterval || 30000;
        
        this.eventSource = null;
        this.reconnectAttempts = 0;
        this.isConnected = false;
        this.eventHandlers = new Map();
        this.messageQueue = [];
        
        // Bind methods
        this.connect = this.connect.bind(this);
        this.disconnect = this.disconnect.bind(this);
        this.on = this.on.bind(this);
        this.off = this.off.bind(this);
        this.emit = this.emit.bind(this);
        this.reconnect = this.reconnect.bind(this);
        
        // Auto-connect
        this.connect();
    }
    
    // Connect to SSE endpoint
    connect() {
        try {
            // Add query parameters for tracking
            const url = new URL(this.url, window.location.origin);
            url.searchParams.set('_', Date.now());
            
            this.eventSource = new EventSource(url.toString());
            
            // Connection events
            this.eventSource.onopen = () => {
                this.isConnected = true;
                this.reconnectAttempts = 0;
                console.log('SSE: Connected');
                this.emit('open');
                this.startHeartbeat();
            };
            
            this.eventSource.onerror = (error) => {
                console.error('SSE: Error', error);
                this.isConnected = false;
                this.emit('error', error);
                this.reconnect();
            };
            
            // Message handling
            this.eventSource.onmessage = (event) => {
                try {
                    const data = JSON.parse(event.data);
                    this.emit('message', data);
                    
                    // Route to specific event handlers
                    if (data.type) {
                        this.emit(data.type, data);
                    }
                    
                    // Store last event ID
                    if (event.lastEventId) {
                        this.lastEventId = event.lastEventId;
                    }
                } catch (e) {
                    console.error('SSE: Parse error', e);
                    this.emit('error', e);
                }
            };
            
            // Handle specific event types
            this.eventSource.addEventListener('heartbeat', (event) => {
                this.emit('heartbeat', JSON.parse(event.data));
            });
            
            this.eventSource.addEventListener('ping', (event) => {
                this.emit('ping', JSON.parse(event.data));
            });
            
        } catch (error) {
            console.error('SSE: Connection error', error);
            this.emit('error', error);
            this.reconnect();
        }
    }
    
    // Disconnect from SSE
    disconnect() {
        if (this.eventSource) {
            this.eventSource.close();
            this.eventSource = null;
            this.isConnected = false;
            this.stopHeartbeat();
            this.emit('close');
            console.log('SSE: Disconnected');
        }
    }
    
    // Reconnect with exponential backoff
    reconnect() {
        if (this.reconnectAttempts >= this.maxReconnectAttempts) {
            console.error('SSE: Max reconnect attempts reached');
            this.emit('error', new Error('Max reconnect attempts reached'));
            return;
        }
        
        const delay = Math.min(
            this.reconnectDelay * Math.pow(1.5, this.reconnectAttempts),
            30000
        );
        
        this.reconnectAttempts++;
        
        console.log(`SSE: Reconnecting in ${delay}ms (attempt ${this.reconnectAttempts})`);
        this.emit('reconnecting', { attempt: this.reconnectAttempts, delay });
        
        setTimeout(() => {
            this.disconnect();
            this.connect();
        }, delay);
    }
    
    // Event handling
    on(event, handler) {
        if (!this.eventHandlers.has(event)) {
            this.eventHandlers.set(event, []);
        }
        this.eventHandlers.get(event).push(handler);
    }
    
    off(event, handler) {
        if (!this.eventHandlers.has(event)) return;
        
        const handlers = this.eventHandlers.get(event);
        const index = handlers.indexOf(handler);
        if (index !== -1) {
            handlers.splice(index, 1);
        }
        
        if (handlers.length === 0) {
            this.eventHandlers.delete(event);
        }
    }
    
    emit(event, data) {
        if (!this.eventHandlers.has(event)) return;
        
        const handlers = this.eventHandlers.get(event);
        handlers.forEach(handler => {
            try {
                handler(data);
            } catch (error) {
                console.error(`SSE: Handler error for ${event}`, error);
            }
        });
    }
    
    // Heartbeat management
    startHeartbeat() {
        this.stopHeartbeat();
        this.heartbeatTimer = setInterval(() => {
            this.emit('heartbeat', { timestamp: Date.now() });
        }, this.heartbeatInterval);
    }
    
    stopHeartbeat() {
        if (this.heartbeatTimer) {
            clearInterval(this.heartbeatTimer);
            this.heartbeatTimer = null;
        }
    }
}

// ============================================================================
// SSE REACT HOOK
// ============================================================================
import { useState, useEffect, useRef, useCallback } from 'react';

function useSSE(options = {}) {
    const [isConnected, setIsConnected] = useState(false);
    const [lastEvent, setLastEvent] = useState(null);
    const [error, setError] = useState(null);
    
    const sseRef = useRef(null);
    const eventHandlers = useRef(new Map());
    
    const connect = useCallback(() => {
        if (sseRef.current) {
            sseRef.current.disconnect();
        }
        
        const sse = new SSEConnection(options);
        
        sse.on('open', () => {
            setIsConnected(true);
            setError(null);
        });
        
        sse.on('close', () => {
            setIsConnected(false);
        });
        
        sse.on('error', (err) => {
            setError(err);
            setIsConnected(false);
        });
        
        sse.on('message', (data) => {
            setLastEvent(data);
        });
        
        // Register custom handlers
        eventHandlers.current.forEach((handler, event) => {
            sse.on(event, handler);
        });
        
        sseRef.current = sse;
    }, [options]);
    
    const disconnect = useCallback(() => {
        if (sseRef.current) {
            sseRef.current.disconnect();
            sseRef.current = null;
            setIsConnected(false);
        }
    }, []);
    
    const on = useCallback((event, handler) => {
        eventHandlers.current.set(event, handler);
        if (sseRef.current) {
            sseRef.current.on(event, handler);
        }
    }, []);
    
    useEffect(() => {
        connect();
        return () => disconnect();
    }, [connect, disconnect]);
    
    return {
        isConnected,
        lastEvent,
        error,
        connect,
        disconnect,
        on
    };
}

export { SSEConnection, useSSE };
```

## P24.3 SSE Monitoring Dashboard

### SSE Monitoring Dashboard

```bash
#!/bin/bash
# sse-monitor.sh - SSE Monitoring Dashboard

echo "=== SSE Monitoring Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get active connections
get_active_connections() {
    local conns=$(netstat -an | grep ':443' | grep ESTABLISHED | wc -l)
    echo "  Active Connections: $conns"
}

# Function: Get event rate
get_event_rate() {
    local events=$(tail -60 /var/log/nginx/sse.log 2>/dev/null | grep -c '"event":')
    echo "  Event Rate: $((events / 1)) events/min"
}

# Function: Get cache performance
get_cache_performance() {
    local hits=$(tail -1000 /var/log/nginx/sse.log 2>/dev/null | grep -c '"cache_status":"HIT"')
    local total=$(tail -1000 /var/log/nginx/sse.log 2>/dev/null | wc -l)
    if [ $total -gt 0 ]; then
        local rate=$((hits * 100 / total))
        echo "  Cache Hit Rate: $rate%"
    else
        echo "  Cache Hit Rate: N/A"
    fi
}

# Function: Get top streams
get_top_streams() {
    echo "  Top Event Streams:"
    tail -10000 /var/log/nginx/sse.log 2>/dev/null | \
        grep -o '"event_stream":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | head -5 | \
        while read count stream; do
            echo "    $stream: $count events"
        done
}

# Function: Get error rate
get_error_rate() {
    local errors=$(tail -1000 /var/log/nginx/sse.log 2>/dev/null | grep -c '"status":5[0-9][0-9]')
    echo "  Error Rate: $errors%"
}

# Function: Get latency
get_latency() {
    local avg=$(tail -100 /var/log/nginx/sse.log 2>/dev/null | \
        grep -o '"request_time":[0-9.]*' | \
        cut -d':' -f2 | awk '{sum+=$1} END {if(NR>0) print sum/NR; else print "N/A"}')
    echo "  Avg Latency: ${avg}s"
}

# Main display
while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              SSE MONITORING DASHBOARD                         ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 SSE STATUS:"
    get_active_connections
    get_event_rate
    get_error_rate
    get_latency
    echo ""
    
    echo "💾 CACHE PERFORMANCE:"
    get_cache_performance
    echo ""
    
    echo "📈 TOP STREAMS:"
    get_top_streams
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into implementing enterprise-grade Server-Sent Events with Nginx. Use these techniques to build real-time, event-driven applications at scale.
