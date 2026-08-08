# Primer 37: Nginx for Real-Time Notifications

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for real-time notifications. Understanding these concepts is essential for building modern, event-driven notification systems at scale.

## P37.1 Real-Time Notification Architecture

### Notification Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    NOTIFICATION ARCHITECTURE                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX NOTIFICATION GATEWAY                     │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    DELIVERY CHANNELS                      │ │      │
│  │  │  • WebSocket       • SSE              • Webhooks         │ │      │
│  │  │  • Email           • SMS              • Push            │ │      │
│  │  │  • In-App          • Desktop          • Slack           │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    ROUTING & FILTERING                    │ │      │
│  │  │  • User Preferences  • Device Targeting  • Priority      │ │      │
│  │  │  • Channel Selection  • Deduplication    • Batching     │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    DELIVERY OPTIMIZATION                  │ │      │
│  │  │  • Throttling        • Retry Logic        • Queuing      │ │      │
│  │  │  • Dead Letter Queue  • Delivery Receipts  • Analytics   │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NOTIFICATION SERVICES                         │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ WebSocket  │  │ SSE        │  │ Webhook    │  │ Email    │ │      │
│  │  │ Service    │  │ Service    │  │ Service    │  │ Service  │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Notification Configuration

```nginx
# nginx-notifications.conf - Complete Notification Gateway
# ============================================================================
# NGINX REAL-TIME NOTIFICATION GATEWAY
# Complete production-ready notification configuration
# ============================================================================

http {
    # =========================================================================
    # NOTIFICATION SETTINGS
    # =========================================================================
    # Connection management
    keepalive_timeout 300s;
    keepalive_requests 10000;
    
    # Buffer settings
    client_header_buffer_size 4k;
    large_client_header_buffers 8 8k;
    client_max_body_size 10M;
    client_body_buffer_size 128k;
    
    # Proxy settings
    proxy_buffering off;
    proxy_request_buffering off;
    proxy_read_timeout 3600s;
    proxy_connect_timeout 75s;
    proxy_send_timeout 3600s;
    
    # =========================================================================
    # NOTIFICATION CACHING
    # =========================================================================
    proxy_cache_path /var/cache/nginx/notification_cache
        levels=1:2
        keys_zone=notification_cache:200m
        max_size=2g
        inactive=1h
        use_temp_path=off;
    
    # =========================================================================
    # NOTIFICATION UPSTREAMS
    # =========================================================================
    # WebSocket Notification Service
    upstream ws_notification {
        least_conn;
        server ws-notify1:8001 max_fails=3 fail_timeout=30s;
        server ws-notify2:8001 max_fails=3 fail_timeout=30s;
        server ws-notify3:8001 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # SSE Notification Service
    upstream sse_notification {
        least_conn;
        server sse-notify1:8002 max_fails=3 fail_timeout=30s;
        server sse-notify2:8002 max_fails=3 fail_timeout=30s;
        server sse-notify3:8002 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Webhook Delivery Service
    upstream webhook_delivery {
        server webhook1:8003 max_fails=3 fail_timeout=30s;
        server webhook2:8003 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Email Service
    upstream email_service {
        server email1:8004 max_fails=3 fail_timeout=30s;
        server email2:8004 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Push Notification Service
    upstream push_service {
        server push1:8005 max_fails=3 fail_timeout=30s;
        server push2:8005 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # NOTIFICATION SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name notify.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/notify.crt;
        ssl_certificate_key /etc/nginx/ssl/notify.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1h;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        
        # Notification headers
        add_header X-Notification-Gateway "nginx" always;
        add_header X-Notification-Version "2.0.0" always;
        
        # =========================================================================
        # WEBSOCKET NOTIFICATIONS
        # =========================================================================
        location /ws/notifications {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=ws_notify burst=5 nodelay;
            limit_conn ws_conn 10;
            
            # WebSocket upgrade
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            
            # Disable buffering
            proxy_buffering off;
            proxy_cache off;
            
            # Timeouts
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
            
            proxy_pass http://ws_notification;
        }
        
        # =========================================================================
        # SSE NOTIFICATIONS
        # =========================================================================
        location /sse/notifications {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=sse_notify burst=10 nodelay;
            
            # SSE headers
            add_header Content-Type "text/event-stream";
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            add_header X-Accel-Buffering "no";
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            
            # Disable buffering
            proxy_buffering off;
            proxy_cache off;
            
            # Timeouts
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
            
            proxy_pass http://sse_notification;
        }
        
        # =========================================================================
        # WEBHOOK DELIVERY
        # =========================================================================
        location /webhooks/deliver {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=webhook_delivery burst=5 nodelay;
            
            # Webhook settings
            client_max_body_size 10M;
            client_body_buffer_size 128k;
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Webhook-ID $http_x_webhook_id;
            proxy_set_header X-Webhook-URL $http_x_webhook_url;
            proxy_set_header X-Webhook-Secret $http_x_webhook_secret;
            
            # Buffering
            proxy_buffering on;
            proxy_buffer_size 16k;
            proxy_buffers 16 16k;
            proxy_busy_buffers_size 32k;
            
            # Timeouts
            proxy_read_timeout 30s;
            proxy_connect_timeout 10s;
            proxy_send_timeout 30s;
            
            # Retry
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
            proxy_next_upstream_tries 3;
            proxy_next_upstream_timeout 30s;
            
            proxy_pass http://webhook_delivery;
        }
        
        # =========================================================================
        # EMAIL NOTIFICATIONS
        # =========================================================================
        location /email/send {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=email_send burst=10 nodelay;
            
            # Email settings
            client_max_body_size 20M;
            client_body_buffer_size 256k;
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Email-To $http_x_email_to;
            proxy_set_header X-Email-Template $http_x_email_template;
            
            # Buffering
            proxy_buffering on;
            proxy_buffer_size 16k;
            proxy_buffers 16 16k;
            proxy_busy_buffers_size 32k;
            
            # Timeouts
            proxy_read_timeout 60s;
            proxy_connect_timeout 10s;
            proxy_send_timeout 60s;
            
            proxy_pass http://email_service;
        }
        
        # =========================================================================
        # PUSH NOTIFICATIONS
        # =========================================================================
        location /push/send {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Rate limiting
            limit_req zone=push_send burst=20 nodelay;
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Device-Token $http_x_device_token;
            proxy_set_header X-Platform $http_x_platform;
            
            # Timeouts
            proxy_read_timeout 10s;
            proxy_connect_timeout 5s;
            proxy_send_timeout 10s;
            
            # No caching
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            proxy_pass http://push_service;
        }
        
        # =========================================================================
        # NOTIFICATION PREFERENCES
        # =========================================================================
        location /preferences/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            
            # Cache preferences
            proxy_cache notification_cache;
            proxy_cache_key $scheme$host$request_uri$auth_user_id;
            proxy_cache_valid 200 5m;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://preference_service;
        }
        
        # =========================================================================
        # NOTIFICATION STATUS
        # =========================================================================
        location /notifications/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "active_connections":$(netstat -an | grep ':443' | grep ESTABLISHED | wc -l),
                "websocket_connections":$(netstat -an | grep ':443' | grep ESTABLISHED | grep -c "Upgrade"),
                "sse_connections":$(netstat -an | grep ':443' | grep ESTABLISHED | grep -c "event-stream"),
                "webhooks_delivered":$(tail -10000 /var/log/nginx/access.log | grep -c "/webhooks/deliver"),
                "emails_sent":$(tail -10000 /var/log/nginx/access.log | grep -c "/email/send"),
                "push_notifications":$(tail -10000 /var/log/nginx/access.log | grep -c "/push/send"),
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
        # HEALTH CHECK
        # =========================================================================
        location /health {
            access_log off;
            return 200 "healthy\n";
        }
    }
}
```

## P37.2 Notification Client Library

### Complete Notification Client

```javascript
// notification-client.js - Complete Notification Client
// ============================================================================
// NOTIFICATION CLIENT LIBRARY
// Production-ready notification client with enterprise features
// ============================================================================

class NotificationClient {
    constructor(options = {}) {
        this.baseUrl = options.baseUrl || 'https://notify.example.com';
        this.apiKey = options.apiKey || '';
        this.userId = options.userId || '';
        this.debug = options.debug || false;
        
        this.ws = null;
        this.sse = null;
        this.listeners = new Map();
        this.notificationQueue = [];
        this.isConnected = false;
        this.reconnectAttempts = 0;
        this.maxReconnectAttempts = options.maxReconnectAttempts || 10;
        this.reconnectDelay = options.reconnectDelay || 3000;
        
        // Connect to WebSocket
        this.connectWebSocket();
        this.connectSSE();
    }
    
    // =========================================================================
    // WEBSOCKET CONNECTION
    // =========================================================================
    connectWebSocket() {
        try {
            const wsUrl = this.baseUrl.replace('https', 'wss') + '/ws/notifications';
            this.ws = new WebSocket(wsUrl, ['notification-protocol']);
            
            this.ws.onopen = () => {
                console.log('Notification WS: Connected');
                this.isConnected = true;
                this.reconnectAttempts = 0;
                this.authenticate();
                this.flushQueue();
                this.emit('connected');
            };
            
            this.ws.onclose = (event) => {
                console.log('Notification WS: Disconnected', event.code);
                this.isConnected = false;
                this.emit('disconnected', { code: event.code });
                this.reconnectWebSocket();
            };
            
            this.ws.onerror = (error) => {
                console.error('Notification WS: Error', error);
                this.emit('error', error);
            };
            
            this.ws.onmessage = (event) => {
                try {
                    const data = JSON.parse(event.data);
                    this.handleNotification(data);
                } catch (error) {
                    console.error('Notification WS: Parse error', error);
                }
            };
            
        } catch (error) {
            console.error('Notification WS: Connection error', error);
            this.reconnectWebSocket();
        }
    }
    
    // =========================================================================
    // SSE CONNECTION
    // =========================================================================
    connectSSE() {
        try {
            const sseUrl = this.baseUrl + '/sse/notifications';
            this.sse = new EventSource(sseUrl);
            
            this.sse.onopen = () => {
                console.log('Notification SSE: Connected');
                this.emit('sse-connected');
            };
            
            this.sse.onerror = (error) => {
                console.error('Notification SSE: Error', error);
                this.emit('sse-error', error);
            };
            
            this.sse.onmessage = (event) => {
                try {
                    const data = JSON.parse(event.data);
                    this.handleNotification(data);
                } catch (error) {
                    console.error('Notification SSE: Parse error', error);
                }
            };
            
        } catch (error) {
            console.error('Notification SSE: Connection error', error);
        }
    }
    
    // =========================================================================
    // AUTHENTICATION
    // =========================================================================
    authenticate() {
        if (this.ws && this.ws.readyState === WebSocket.OPEN) {
            this.ws.send(JSON.stringify({
                type: 'auth',
                apiKey: this.apiKey,
                userId: this.userId,
                timestamp: Date.now()
            }));
        }
    }
    
    // =========================================================================
    // NOTIFICATION HANDLING
    // =========================================================================
    handleNotification(data) {
        if (this.debug) {
            console.log('Notification received:', data);
        }
        
        // Store notification
        this.notificationQueue.push(data);
        if (this.notificationQueue.length > 100) {
            this.notificationQueue.shift();
        }
        
        // Emit event
        this.emit('notification', data);
        
        // Route by type
        if (data.type) {
            this.emit(data.type, data);
        }
        
        // Show browser notification
        if (data.showNotification !== false) {
            this.showBrowserNotification(data);
        }
    }
    
    // =========================================================================
    // BROWSER NOTIFICATIONS
    // =========================================================================
    showBrowserNotification(data) {
        if (!('Notification' in window)) return;
        
        if (Notification.permission === 'granted') {
            new Notification(data.title || 'Notification', {
                body: data.body || '',
                icon: data.icon || '/favicon.ico',
                tag: data.id || '',
                data: data
            });
        } else if (Notification.permission === 'default') {
            Notification.requestPermission();
        }
    }
    
    // =========================================================================
    // SEND NOTIFICATION
    // =========================================================================
    sendNotification(data) {
        const payload = {
            type: 'send',
            data: data,
            timestamp: Date.now()
        };
        
        if (this.isConnected) {
            this.ws.send(JSON.stringify(payload));
        } else {
            this.notificationQueue.push(payload);
        }
    }
    
    // =========================================================================
    // QUEUE MANAGEMENT
    // =========================================================================
    flushQueue() {
        while (this.notificationQueue.length > 0) {
            const item = this.notificationQueue.shift();
            if (item.type === 'send') {
                this.sendNotification(item.data);
            }
        }
    }
    
    // =========================================================================
    // RECONNECT
    // =========================================================================
    reconnectWebSocket() {
        if (this.reconnectAttempts >= this.maxReconnectAttempts) {
            console.error('Notification WS: Max reconnect attempts reached');
            this.emit('error', new Error('Max reconnect attempts reached'));
            return;
        }
        
        const delay = Math.min(
            this.reconnectDelay * Math.pow(1.5, this.reconnectAttempts),
            30000
        );
        
        this.reconnectAttempts++;
        console.log(`Notification WS: Reconnecting in ${delay}ms`);
        
        setTimeout(() => {
            this.connectWebSocket();
        }, delay);
    }
    
    // =========================================================================
    // EVENT HANDLING
    // =========================================================================
    on(event, handler) {
        if (!this.listeners.has(event)) {
            this.listeners.set(event, []);
        }
        this.listeners.get(event).push(handler);
        return this;
    }
    
    off(event, handler) {
        if (!this.listeners.has(event)) return this;
        
        const handlers = this.listeners.get(event);
        const index = handlers.indexOf(handler);
        if (index !== -1) {
            handlers.splice(index, 1);
        }
        return this;
    }
    
    emit(event, data) {
        if (!this.listeners.has(event)) return;
        
        const handlers = this.listeners.get(event);
        handlers.forEach(handler => {
            try {
                handler(data);
            } catch (error) {
                console.error(`Notification: Handler error for ${event}`, error);
            }
        });
    }
    
    // =========================================================================
    // UTILITY METHODS
    // =========================================================================
    getNotifications() {
        return [...this.notificationQueue];
    }
    
    clearNotifications() {
        this.notificationQueue = [];
    }
    
    disconnect() {
        if (this.ws) {
            this.ws.close();
        }
        if (this.sse) {
            this.sse.close();
        }
        this.isConnected = false;
    }
}

// React Hook
function useNotifications(options = {}) {
    const [notifications, setNotifications] = useState([]);
    const [isConnected, setIsConnected] = useState(false);
    const [lastNotification, setLastNotification] = useState(null);
    
    const clientRef = useRef(null);
    const handlers = useRef(new Map());
    
    useEffect(() => {
        const client = new NotificationClient(options);
        
        client.on('connected', () => setIsConnected(true));
        client.on('disconnected', () => setIsConnected(false));
        client.on('notification', (data) => {
            setNotifications(prev => [data, ...prev].slice(0, 50));
            setLastNotification(data);
        });
        
        // Register custom handlers
        handlers.current.forEach((handler, event) => {
            client.on(event, handler);
        });
        
        clientRef.current = client;
        
        return () => {
            client.disconnect();
        };
    }, []);
    
    const sendNotification = useCallback((data) => {
        if (clientRef.current) {
            clientRef.current.sendNotification(data);
        }
    }, []);
    
    const clearNotifications = useCallback(() => {
        if (clientRef.current) {
            clientRef.current.clearNotifications();
            setNotifications([]);
        }
    }, []);
    
    const on = useCallback((event, handler) => {
        handlers.current.set(event, handler);
        if (clientRef.current) {
            clientRef.current.on(event, handler);
        }
    }, []);
    
    return {
        notifications,
        isConnected,
        lastNotification,
        sendNotification,
        clearNotifications,
        on
    };
}

export { NotificationClient, useNotifications };
```

## P37.3 Notification Monitoring

### Notification Monitoring Dashboard

```bash
#!/bin/bash
# notification-monitor.sh - Notification monitoring

echo "=== Notification Monitoring Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get delivery stats
get_delivery_stats() {
    echo "  Delivery Statistics:"
    local total=$(tail -1000 /var/log/nginx/access.log | grep -c "/notifications/")
    local delivered=$(tail -1000 /var/log/nginx/access.log | grep "/notifications/" | grep -c '"status":200')
    local failed=$(tail -1000 /var/log/nginx/access.log | grep "/notifications/" | grep -c '"status":5[0-9][0-9]')
    echo "    Total: $total"
    echo "    Delivered: $delivered"
    echo "    Failed: $failed"
}

# Function: Get channel stats
get_channel_stats() {
    echo "  Channel Statistics:"
    local ws=$(tail -1000 /var/log/nginx/access.log | grep -c "/ws/notifications")
    local sse=$(tail -1000 /var/log/nginx/access.log | grep -c "/sse/notifications")
    local webhook=$(tail -1000 /var/log/nginx/access.log | grep -c "/webhooks/deliver")
    local email=$(tail -1000 /var/log/nginx/access.log | grep -c "/email/send")
    local push=$(tail -1000 /var/log/nginx/access.log | grep -c "/push/send")
    echo "    WebSocket: $ws"
    echo "    SSE: $sse"
    echo "    Webhook: $webhook"
    echo "    Email: $email"
    echo "    Push: $push"
}

# Function: Get active connections
get_active_connections() {
    local ws_conns=$(netstat -an | grep ':443' | grep ESTABLISHED | grep -c "Upgrade")
    local sse_conns=$(netstat -an | grep ':443' | grep ESTABLISHED | grep -c "event-stream")
    echo "  Active Connections:"
    echo "    WebSocket: $ws_conns"
    echo "    SSE: $sse_conns"
}

# Function: Get delivery rate
get_delivery_rate() {
    local rate=$(tail -60 /var/log/nginx/access.log | grep -c "/notifications/")
    echo "  Delivery Rate: $((rate / 1)) notifications/min"
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
    echo "║              NOTIFICATION MONITORING DASHBOARD                ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 NOTIFICATION STATISTICS:"
    get_delivery_stats
    echo ""
    get_channel_stats
    echo ""
    get_active_connections
    echo ""
    get_delivery_rate
    get_error_rate
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx for real-time notifications. Use these techniques to build modern, event-driven notification systems at scale.
