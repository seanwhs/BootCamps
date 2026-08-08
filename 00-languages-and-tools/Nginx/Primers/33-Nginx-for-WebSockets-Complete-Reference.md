# Primer 33: Nginx for WebSockets - Complete Reference

## The Target

This primer provides the definitive, comprehensive reference guide for using WebSockets with Nginx. It consolidates all WebSocket patterns, practices, and configurations into a single complete reference.

## P33.1 WebSocket Fundamentals

### WebSocket Architecture

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    WEBSOCKET ARCHITECTURE                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX WEBSOCKET GATEWAY                        │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    CONNECTION MANAGEMENT                   │ │      │
│  │  │  • Upgrade Handling  • Keep-Alive     • Timeouts          │ │      │
│  │  │  • Load Balancing    • Sticky Sessions • Heartbeat       │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    PROTOCOL HANDLING                      │ │      │
│  │  │  • WebSocket (WS)   • Secure WS (WSS)   • Subprotocols   │ │      │
│  │  │  • Message Framing  • Compression        • Extensions    │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    CLUSTER MANAGEMENT                     │ │      │
│  │  │  • Node Discovery   • State Sync        • Failover        │ │      │
│  │  │  • Broadcast        • Message Routing   • Sharding       │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐           │
│  │              │              │              │              │           │
│  ▼              ▼              ▼              ▼              ▼           │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐           │
│  │ WS     │  │ WS     │  │ WS     │  │ WS     │  │ WS     │           │
│  │ Server │  │ Server │  │ Server │  │ Server │  │ Server │           │
│  │ 1      │  │ 2      │  │ 3      │  │ 4      │  │ 5      │           │
│  └────────┘  └────────┘  └────────┘  └────────┘  └────────┘           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete WebSocket Configuration

```nginx
# nginx-websocket.conf - Complete WebSocket Configuration
# ============================================================================
# NGINX WEBSOCKET COMPLETE REFERENCE
# All WebSocket patterns in one configuration
# ============================================================================

http {
    # =========================================================================
    # WEBSOCKET SPECIFIC SETTINGS
    # =========================================================================
    # Connection management
    keepalive_timeout 300s;
    keepalive_requests 10000;
    
    # Buffer sizes
    client_header_buffer_size 4k;
    large_client_header_buffers 8 8k;
    
    # Disable buffering for WebSockets
    proxy_buffering off;
    proxy_request_buffering off;
    
    # Long timeouts for WebSocket
    proxy_read_timeout 3600s;
    proxy_connect_timeout 75s;
    proxy_send_timeout 3600s;
    
    # =========================================================================
    # WEBSOCKET UPSTREAMS
    # =========================================================================
    # Standard WebSocket cluster
    upstream websocket_cluster {
        # Sticky sessions with IP hash
        ip_hash;
        
        server ws1:8000 max_fails=3 fail_timeout=30s;
        server ws2:8000 max_fails=3 fail_timeout=30s;
        server ws3:8000 max_fails=3 fail_timeout=30s;
        server ws4:8000 max_fails=3 fail_timeout=30s;
        server ws5:8000 max_fails=3 fail_timeout=30s;
        
        keepalive 64;
        keepalive_requests 10000;
        keepalive_timeout 300s;
    }
    
    # Sticky session with cookie
    upstream sticky_websocket {
        # Use cookie for sticky sessions
        sticky cookie ws_id expires=1h path=/;
        
        server ws1:8000 max_fails=3 fail_timeout=30s;
        server ws2:8000 max_fails=3 fail_timeout=30s;
        server ws3:8000 max_fails=3 fail_timeout=30s;
        
        keepalive 64;
    }
    
    # Least connections (dynamic load balancing)
    upstream least_conn_websocket {
        least_conn;
        
        server ws1:8000 max_fails=3 fail_timeout=30s;
        server ws2:8000 max_fails=3 fail_timeout=30s;
        server ws3:8000 max_fails=3 fail_timeout=30s;
        
        keepalive 64;
    }
    
    # =========================================================================
    # WEBSOCKET SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name ws.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/ws.crt;
        ssl_certificate_key /etc/nginx/ssl/ws.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1h;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        
        # WebSocket specific headers
        add_header X-WebSocket-Gateway "nginx" always;
        
        # =========================================================================
        # WEBSOCKET UPGRADE LOCATION
        # =========================================================================
        location /ws/ {
            # Required for WebSocket upgrade
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            # WebSocket subprotocols
            proxy_set_header Sec-WebSocket-Protocol $http_sec_websocket_protocol;
            
            # Disable buffering
            proxy_buffering off;
            proxy_cache off;
            
            # Long timeouts
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
            
            # Retry on failure
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
            proxy_next_upstream_tries 2;
            
            # Route to WebSocket cluster
            proxy_pass http://websocket_cluster;
        }
        
        # =========================================================================
        # WEBSOCKET WITH AUTHENTICATION
        # =========================================================================
        location /ws/auth/ {
            # Authentication check
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Upgrade headers
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            # Headers with auth
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            
            proxy_buffering off;
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
            
            proxy_pass http://websocket_cluster;
        }
        
        # =========================================================================
        # WEBSOCKET WITH RATE LIMITING
        # =========================================================================
        location /ws/limited/ {
            # Rate limiting for WebSocket connections
            limit_req zone=ws_limit burst=5 nodelay;
            limit_conn ws_conn 10;
            
            # Upgrade headers
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_buffering off;
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
            
            # Rate limit response
            proxy_intercept_errors on;
            error_page 429 = /ws-rate-limited;
            
            proxy_pass http://websocket_cluster;
        }
        
        # =========================================================================
        # WEBSOCKET WITH CUSTOM PROTOCOLS
        # =========================================================================
        location /ws/protocol/ {
            # Protocol-specific routing
            set $ws_protocol "default";
            
            if ($http_sec_websocket_protocol ~* "v1") {
                set $ws_protocol "v1";
            }
            if ($http_sec_websocket_protocol ~* "v2") {
                set $ws_protocol "v2";
            }
            
            # Route based on protocol
            if ($ws_protocol = "v1") {
                proxy_pass http://ws-v1-backend/;
            }
            if ($ws_protocol = "v2") {
                proxy_pass http://ws-v2-backend/;
            }
            
            # Upgrade headers
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Sec-WebSocket-Protocol $http_sec_websocket_protocol;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_buffering off;
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
        }
        
        # =========================================================================
        # WEBSOCKET STATS & MONITORING
        # =========================================================================
        location /ws/stats {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "active_connections":$(netstat -an | grep ':443' | grep ESTABLISHED | wc -l),
                "websocket_connections":$(netstat -an | grep ':443' | grep ESTABLISHED | grep -c "Upgrade"),
                "messages_sent":$(tail -10000 /var/log/nginx/access.log | grep -c "WebSocket"),
                "messages_received":$(tail -10000 /var/log/nginx/access.log | grep -c "WebSocket"),
                "timestamp":"$time_iso8601"
            }';
            add_header Content-Type application/json;
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
            
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
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
        # RATE LIMIT ERROR
        # =========================================================================
        location = /ws-rate-limited {
            return 429 '{"error":"WebSocket connection limit exceeded"}';
            add_header Content-Type application/json;
            add_header Retry-After 60;
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

## P33.2 WebSocket Security

### WebSocket Security Configuration

```nginx
# nginx-websocket-security.conf - WebSocket Security
# ============================================================================
# NGINX WEBSOCKET SECURITY
# Complete WebSocket security configuration
# ============================================================================

http {
    # =========================================================================
    # WEBSOCKET SECURITY HEADERS
    # =========================================================================
    server {
        listen 443 ssl http2;
        server_name ws.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/ws.crt;
        ssl_certificate_key /etc/nginx/ssl/ws.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        add_header X-XSS-Protection "1; mode=block" always;
        
        # WebSocket specific security
        add_header Cross-Origin-Resource-Policy "same-site" always;
        add_header Cross-Origin-Opener-Policy "same-origin" always;
        
        # =========================================================================
        # WEBSOCKET ORIGIN VALIDATION
        # =========================================================================
        location /ws/ {
            # Validate Origin header
            if ($http_origin !~* "^https?://(example\.com|api\.example\.com)$") {
                return 403 '{"error":"Invalid origin"}';
                add_header Content-Type application/json;
            }
            
            # Validate Host header
            if ($http_host !~* "^(ws\.example\.com|api\.example\.com)$") {
                return 400 '{"error":"Invalid host"}';
                add_header Content-Type application/json;
            }
            
            # Upgrade headers
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_buffering off;
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
            
            proxy_pass http://websocket_cluster;
        }
        
        # =========================================================================
        # WEBSOCKET DOS PROTECTION
        # =========================================================================
        location /ws/ {
            # Connection limiting
            limit_conn ws_conn 10;
            
            # Rate limiting
            limit_req zone=ws_limit burst=5 nodelay;
            
            # Connection timeouts (prevent DoS)
            client_body_timeout 5s;
            client_header_timeout 5s;
            send_timeout 10s;
            
            # Buffer limits
            client_body_buffer_size 128k;
            client_header_buffer_size 1k;
            
            # Upgrade headers
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_buffering off;
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
            
            proxy_pass http://websocket_cluster;
        }
    }
}
```

## P33.3 WebSocket Client Library

### Complete WebSocket Client

```javascript
// websocket-client.js - Complete WebSocket Client
// ============================================================================
// WEBSOCKET CLIENT LIBRARY
// Production-ready WebSocket client with enterprise features
// ============================================================================

class WebSocketClient {
    constructor(options = {}) {
        this.url = options.url || 'wss://ws.example.com/ws/';
        this.reconnectDelay = options.reconnectDelay || 3000;
        this.maxReconnectAttempts = options.maxReconnectAttempts || 10;
        this.heartbeatInterval = options.heartbeatInterval || 30000;
        this.timeout = options.timeout || 30000;
        this.protocols = options.protocols || [];
        this.headers = options.headers || {};
        
        this.ws = null;
        this.isConnected = false;
        this.isConnecting = false;
        this.reconnectAttempts = 0;
        this.messageQueue = [];
        this.eventHandlers = new Map();
        this.heartbeatTimer = null;
        this.reconnectTimer = null;
        
        this.connect();
    }
    
    // Connect to WebSocket
    connect() {
        if (this.isConnecting) return;
        this.isConnecting = true;
        
        try {
            // Build WebSocket URL with query params
            const url = new URL(this.url);
            if (this.headers['X-User-ID']) {
                url.searchParams.set('user_id', this.headers['X-User-ID']);
            }
            if (this.headers['X-Session-ID']) {
                url.searchParams.set('session_id', this.headers['X-Session-ID']);
            }
            
            // Create WebSocket
            this.ws = new WebSocket(url.toString(), this.protocols);
            
            // Connection events
            this.ws.onopen = () => {
                console.log('WebSocket: Connected');
                this.isConnected = true;
                this.isConnecting = false;
                this.reconnectAttempts = 0;
                this.emit('open');
                this.startHeartbeat();
                this.flushMessageQueue();
            };
            
            this.ws.onclose = (event) => {
                console.log('WebSocket: Disconnected', event.code, event.reason);
                this.isConnected = false;
                this.isConnecting = false;
                this.emit('close', { code: event.code, reason: event.reason });
                this.stopHeartbeat();
                
                if (event.code !== 1000) { // Normal closure
                    this.reconnect();
                }
            };
            
            this.ws.onerror = (error) => {
                console.error('WebSocket: Error', error);
                this.emit('error', error);
            };
            
            this.ws.onmessage = (event) => {
                try {
                    const data = JSON.parse(event.data);
                    this.emit('message', data);
                    
                    // Handle heartbeat
                    if (data.type === 'pong') {
                        this.emit('pong', data);
                    }
                } catch (e) {
                    console.error('WebSocket: Parse error', e);
                    this.emit('error', e);
                }
            };
            
        } catch (error) {
            console.error('WebSocket: Connection error', error);
            this.isConnecting = false;
            this.emit('error', error);
            this.reconnect();
        }
    }
    
    // Disconnect
    disconnect() {
        if (this.ws) {
            this.ws.close(1000, 'Normal closure');
            this.ws = null;
        }
        this.isConnected = false;
        this.isConnecting = false;
        this.stopHeartbeat();
        this.clearReconnect();
        this.emit('close', { code: 1000, reason: 'Manual disconnect' });
    }
    
    // Reconnect
    reconnect() {
        if (this.reconnectAttempts >= this.maxReconnectAttempts) {
            console.error('WebSocket: Max reconnect attempts reached');
            this.emit('error', new Error('Max reconnect attempts reached'));
            return;
        }
        
        const delay = Math.min(
            this.reconnectDelay * Math.pow(1.5, this.reconnectAttempts),
            30000
        );
        
        this.reconnectAttempts++;
        console.log(`WebSocket: Reconnecting in ${delay}ms (attempt ${this.reconnectAttempts})`);
        this.emit('reconnecting', { attempt: this.reconnectAttempts, delay });
        
        this.clearReconnect();
        this.reconnectTimer = setTimeout(() => {
            this.connect();
        }, delay);
    }
    
    // Send message
    send(data) {
        if (this.isConnected) {
            try {
                const message = typeof data === 'string' ? data : JSON.stringify(data);
                this.ws.send(message);
                return true;
            } catch (error) {
                console.error('WebSocket: Send error', error);
                this.emit('error', error);
                return false;
            }
        } else {
            // Queue message for later
            this.messageQueue.push(data);
            console.log('WebSocket: Queued message', data);
            return false;
        }
    }
    
    // Flush message queue
    flushMessageQueue() {
        while (this.messageQueue.length > 0) {
            const message = this.messageQueue.shift();
            this.send(message);
        }
    }
    
    // Heartbeat
    startHeartbeat() {
        this.stopHeartbeat();
        this.heartbeatTimer = setInterval(() => {
            if (this.isConnected) {
                this.send({ type: 'ping', timestamp: Date.now() });
                this.emit('ping');
            }
        }, this.heartbeatInterval);
    }
    
    stopHeartbeat() {
        if (this.heartbeatTimer) {
            clearInterval(this.heartbeatTimer);
            this.heartbeatTimer = null;
        }
    }
    
    clearReconnect() {
        if (this.reconnectTimer) {
            clearTimeout(this.reconnectTimer);
            this.reconnectTimer = null;
        }
    }
    
    // Event handling
    on(event, handler) {
        if (!this.eventHandlers.has(event)) {
            this.eventHandlers.set(event, []);
        }
        this.eventHandlers.get(event).push(handler);
        return this;
    }
    
    off(event, handler) {
        if (!this.eventHandlers.has(event)) return this;
        
        const handlers = this.eventHandlers.get(event);
        const index = handlers.indexOf(handler);
        if (index !== -1) {
            handlers.splice(index, 1);
        }
        if (handlers.length === 0) {
            this.eventHandlers.delete(event);
        }
        return this;
    }
    
    emit(event, data) {
        if (!this.eventHandlers.has(event)) return;
        
        const handlers = this.eventHandlers.get(event);
        handlers.forEach(handler => {
            try {
                handler(data);
            } catch (error) {
                console.error(`WebSocket: Handler error for ${event}`, error);
            }
        });
    }
    
    // State
    get state() {
        if (this.isConnected) return 'connected';
        if (this.isConnecting) return 'connecting';
        return 'disconnected';
    }
}

// React Hook
function useWebSocket(options = {}) {
    const [state, setState] = useState('disconnected');
    const [lastMessage, setLastMessage] = useState(null);
    const [error, setError] = useState(null);
    
    const wsRef = useRef(null);
    const handlers = useRef(new Map());
    
    const connect = useCallback(() => {
        if (wsRef.current) {
            wsRef.current.disconnect();
        }
        
        const ws = new WebSocketClient(options);
        
        ws.on('open', () => {
            setState('connected');
            setError(null);
        });
        
        ws.on('close', () => {
            setState('disconnected');
        });
        
        ws.on('error', (err) => {
            setError(err);
            setState('error');
        });
        
        ws.on('message', (data) => {
            setLastMessage(data);
        });
        
        // Register custom handlers
        handlers.current.forEach((handler, event) => {
            ws.on(event, handler);
        });
        
        wsRef.current = ws;
    }, [options]);
    
    const disconnect = useCallback(() => {
        if (wsRef.current) {
            wsRef.current.disconnect();
            wsRef.current = null;
            setState('disconnected');
        }
    }, []);
    
    const send = useCallback((data) => {
        if (wsRef.current) {
            return wsRef.current.send(data);
        }
        return false;
    }, []);
    
    const on = useCallback((event, handler) => {
        handlers.current.set(event, handler);
        if (wsRef.current) {
            wsRef.current.on(event, handler);
        }
    }, []);
    
    useEffect(() => {
        connect();
        return () => disconnect();
    }, [connect, disconnect]);
    
    return {
        state,
        lastMessage,
        error,
        connect,
        disconnect,
        send,
        on
    };
}

export { WebSocketClient, useWebSocket };
```

## P33.4 WebSocket Monitoring

### WebSocket Monitoring Dashboard

```bash
#!/bin/bash
# websocket-monitor.sh - WebSocket monitoring

echo "=== WebSocket Monitoring Dashboard ==="

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

# Function: Get WebSocket connections
get_websocket_connections() {
    local ws_conns=$(netstat -an | grep ':443' | grep ESTABLISHED | grep -c "Upgrade")
    echo "  WebSocket Connections: $ws_conns"
}

# Function: Get message rate
get_message_rate() {
    local msgs=$(tail -60 /var/log/nginx/access.log | grep -c "WebSocket")
    echo "  Message Rate: $((msgs / 1)) messages/min"
}

# Function: Get connection duration
get_connection_duration() {
    local avg=$(tail -100 /var/log/nginx/access.log | \
        grep -o '"request_time":[0-9.]*' | \
        cut -d':' -f2 | awk '{sum+=$1} END {if(NR>0) print sum/NR; else print "N/A"}')
    echo "  Avg Duration: ${avg}s"
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
    echo "║              WEBSOCKET MONITORING DASHBOARD                   ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 WEBSOCKET STATISTICS:"
    get_active_connections
    get_websocket_connections
    get_message_rate
    get_connection_duration
    get_error_rate
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides the definitive, complete reference guide for using WebSockets with Nginx. It consolidates all WebSocket patterns, practices, and configurations into a single complete reference.
