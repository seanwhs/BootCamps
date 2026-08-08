# Primer 34: Nginx for Real-Time Collaboration

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for real-time collaboration applications. Understanding these concepts is essential for building applications like collaborative editing, shared whiteboards, live coding, and multiplayer experiences.

## P34.1 Real-Time Collaboration Architecture

### Collaboration Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    COLLABORATION ARCHITECTURE                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX COLLABORATION GATEWAY                    │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    OPERATIONAL TRANSFORMATION (OT)         │ │      │
│  │  │  • CRDT Support     • Conflict Resolution   • Merge       │ │      │
│  │  │  • History Tracking  • Version Control      • Rebase      │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    PRESENCE MANAGEMENT                    │ │      │
│  │  │  • User Tracking    • Cursor Position     • Typing       │ │      │
│  │  │  • Online/Offline   • Activity Status     • Profiles    │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    SESSION MANAGEMENT                     │ │      │
│  │  │  • Room Creation    • Participant Sync    • Permissions   │ │      │
│  │  │  • State Sharing    • Snapshots           • Replay        │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    COLLABORATION SERVICES                        │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ Document   │  │ Presence   │  │ Session    │  │ History  │ │      │
│  │  │ Service    │  │ Service    │  │ Service    │  │ Service  │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Collaboration Configuration

```nginx
# nginx-collaboration.conf - Complete Collaboration Gateway
# ============================================================================
# NGINX REAL-TIME COLLABORATION GATEWAY
# Complete production-ready collaboration configuration
# ============================================================================

http {
    # =========================================================================
    # COLLABORATION SPECIFIC SETTINGS
    # =========================================================================
    # Long-lived connections
    keepalive_timeout 3600s;
    keepalive_requests 100000;
    
    # Large messages for collaborative documents
    client_max_body_size 50M;
    client_body_buffer_size 1M;
    
    # Buffer settings
    proxy_buffering off;
    proxy_request_buffering off;
    proxy_buffer_size 16k;
    proxy_buffers 16 16k;
    proxy_busy_buffers_size 32k;
    
    # Timeouts
    proxy_read_timeout 3600s;
    proxy_connect_timeout 75s;
    proxy_send_timeout 3600s;
    
    # =========================================================================
    # COLLABORATION CACHING
    # =========================================================================
    proxy_cache_path /var/cache/nginx/document_cache
        levels=1:2
        keys_zone=document_cache:500m
        max_size=5g
        inactive=1h
        use_temp_path=off;
    
    proxy_cache_path /var/cache/nginx/snapshot_cache
        levels=1:2
        keys_zone=snapshot_cache:200m
        max_size=2g
        inactive=30d
        use_temp_path=off;
    
    # =========================================================================
    # COLLABORATION UPSTREAMS
    # =========================================================================
    # Document Service (CRDT/OT)
    upstream document_service {
        least_conn;
        server doc1:8001 max_fails=3 fail_timeout=30s;
        server doc2:8001 max_fails=3 fail_timeout=30s;
        server doc3:8001 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Presence Service
    upstream presence_service {
        least_conn;
        server presence1:8002 max_fails=3 fail_timeout=30s;
        server presence2:8002 max_fails=3 fail_timeout=30s;
        server presence3:8002 max_fails=3 fail_timeout=30s;
        keepalive 64;
    }
    
    # Session Service
    upstream session_service {
        server session1:8003 max_fails=3 fail_timeout=30s;
        server session2:8003 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # History Service
    upstream history_service {
        server history1:8004 max_fails=3 fail_timeout=30s;
        server history2:8004 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # COLLABORATION SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name collab.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/collab.crt;
        ssl_certificate_key /etc/nginx/ssl/collab.key;
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
        
        # Collaboration headers
        add_header X-Collab-Gateway "nginx" always;
        add_header X-Collab-Version "2.0.0" always;
        
        # =========================================================================
        # DOCUMENT OPERATIONS
        # =========================================================================
        location /documents/ {
            # Authentication
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Room routing
            set $document_id $arg_doc_id;
            if ($document_id = "") {
                return 400 '{"error":"Document ID required"}';
                add_header Content-Type application/json;
            }
            
            # Sticky sessions for document
            proxy_set_header X-Document-ID $document_id;
            
            # WebSocket upgrade for real-time
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
            proxy_set_header X-Document-ID $document_id;
            
            # Disable buffering
            proxy_buffering off;
            proxy_cache off;
            
            proxy_pass http://document_service;
        }
        
        # =========================================================================
        # PRESENCE
        # =========================================================================
        location /presence/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # WebSocket for presence
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Room-ID $http_x_room_id;
            
            proxy_buffering off;
            
            proxy_read_timeout 3600s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 3600s;
            
            proxy_pass http://presence_service;
        }
        
        # =========================================================================
        # SESSION MANAGEMENT
        # =========================================================================
        location /sessions/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            # Session operations
            proxy_pass http://session_service;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Cache session data
            proxy_cache document_cache;
            proxy_cache_key $scheme$host$request_uri$auth_user_id;
            proxy_cache_valid 200 5m;
            add_header X-Cache-Status $upstream_cache_status;
        }
        
        # =========================================================================
        # DOCUMENT HISTORY
        # =========================================================================
        location /history/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            set $document_id $arg_doc_id;
            if ($document_id = "") {
                return 400 '{"error":"Document ID required"}';
                add_header Content-Type application/json;
            }
            
            # History operations
            proxy_pass http://history_service;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Document-ID $document_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Cache history
            proxy_cache snapshot_cache;
            proxy_cache_key $scheme$host$request_uri$document_id;
            proxy_cache_valid 200 1h;
            add_header X-Cache-Status $upstream_cache_status;
        }
        
        # =========================================================================
        # DOCUMENT SNAPSHOTS
        # =========================================================================
        location /snapshots/ {
            auth_request /auth/validate;
            auth_request_set $auth_user_id $upstream_http_x_user_id;
            
            set $document_id $arg_doc_id;
            if ($document_id = "") {
                return 400 '{"error":"Document ID required"}';
                add_header Content-Type application/json;
            }
            
            # Snapshot operations
            proxy_pass http://history_service/snapshots;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-User-ID $auth_user_id;
            proxy_set_header X-Document-ID $document_id;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Cache snapshots
            proxy_cache snapshot_cache;
            proxy_cache_key $scheme$host$request_uri$document_id$arg_version;
            proxy_cache_valid 200 30d;
            add_header X-Cache-Status $upstream_cache_status;
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
        # COLLABORATION STATUS
        # =========================================================================
        location /collab/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "active_sessions":$(netstat -an | grep ':443' | grep ESTABLISHED | wc -l),
                "active_documents":$(tail -10000 /var/log/nginx/access.log | grep -o '"X-Document-ID":"[^"]*"' | cut -d'"' -f4 | sort -u | wc -l),
                "active_users":$(tail -10000 /var/log/nginx/access.log | grep -o '"X-User-ID":"[^"]*"' | cut -d'"' -f4 | sort -u | wc -l),
                "document_ops":$(tail -10000 /var/log/nginx/access.log | grep -c "/documents/"),
                "presence_updates":$(tail -10000 /var/log/nginx/access.log | grep -c "/presence/"),
                "history_entries":$(tail -10000 /var/log/nginx/access.log | grep -c "/history/"),
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

## P34.2 Operational Transformation (OT)

### OT Configuration with Lua

```lua
-- ot-handler.lua - Operational Transformation Handler
-- ============================================================================
-- OPERATIONAL TRANSFORMATION HANDLER
-- Real-time collaborative editing with OT
-- ============================================================================

local ot_handler = {}

-- Document store
ot_handler.documents = {}

-- Operation types
ot_handler.OPERATIONS = {
    INSERT = "insert",
    DELETE = "delete",
    UPDATE = "update",
    REPLACE = "replace",
    MOVE = "move",
    FORMAT = "format"
}

-- Apply operation to document
function ot_handler.apply_operation(document, operation)
    local op = operation
    local pos = op.position or 1
    local text = op.text or ""
    local length = op.length or 0
    
    if op.type == ot_handler.OPERATIONS.INSERT then
        -- Insert text at position
        document.text = document.text:sub(1, pos - 1) .. text .. document.text:sub(pos)
    elseif op.type == ot_handler.OPERATIONS.DELETE then
        -- Delete text at position
        document.text = document.text:sub(1, pos - 1) .. document.text:sub(pos + length)
    elseif op.type == ot_handler.OPERATIONS.UPDATE then
        -- Update text at position
        document.text = document.text:sub(1, pos - 1) .. text .. document.text:sub(pos + length)
    elseif op.type == ot_handler.OPERATIONS.REPLACE then
        -- Replace text
        document.text = text
    elseif op.type == ot_handler.OPERATIONS.MOVE then
        -- Move text from one position to another
        local start = op.start or 1
        local end_pos = op.end_pos or #document.text
        local target = op.target or 1
        local moved = document.text:sub(start, end_pos)
        document.text = document.text:sub(1, start - 1) .. document.text:sub(end_pos + 1)
        document.text = document.text:sub(1, target - 1) .. moved .. document.text:sub(target)
    end
    
    document.version = document.version + 1
    document.updated_at = os.time()
    
    return document
end

-- Transform operations (OT)
function ot_handler.transform(op1, op2)
    -- Basic OT transformation
    -- In production, use a proper OT library
    
    local transformed = {op1}
    
    -- Adjust positions based on concurrent operations
    if op1.position and op2.position then
        if op1.position > op2.position then
            if op2.type == ot_handler.OPERATIONS.INSERT then
                op1.position = op1.position + #op2.text
            elseif op2.type == ot_handler.OPERATIONS.DELETE then
                op1.position = op1.position - op2.length
            end
        end
    end
    
    return transformed
end

-- Compose operations
function ot_handler.compose(ops)
    local document = {
        text = "",
        version = 0,
        created_at = os.time(),
        updated_at = os.time()
    }
    
    for _, op in ipairs(ops) do
        document = ot_handler.apply_operation(document, op)
    end
    
    return document
end

-- Session handler
function ot_handler.handle_session(document_id, user_id)
    -- Get or create document
    local doc = ot_handler.documents[document_id]
    if not doc then
        doc = {
            text = "",
            version = 0,
            created_at = os.time(),
            updated_at = os.time(),
            users = {}
        }
        ot_handler.documents[document_id] = doc
    end
    
    -- Add user to document
    doc.users[user_id] = {
        joined_at = os.time(),
        cursor = { line = 1, column = 1 }
    }
    
    -- Return document
    return doc
end

-- Operation handler
function ot_handler.handle_operation(document_id, user_id, operation)
    local doc = ot_handler.documents[document_id]
    if not doc then
        return nil, "Document not found"
    end
    
    -- Check user permission
    if not doc.users[user_id] then
        return nil, "User not in document"
    end
    
    -- Apply operation
    doc = ot_handler.apply_operation(doc, operation)
    
    -- Broadcast to other users
    local broadcast = {
        type = "operation",
        document_id = document_id,
        operation = operation,
        user_id = user_id,
        version = doc.version,
        timestamp = os.time()
    }
    
    -- Store in history
    ot_handler.add_to_history(document_id, broadcast)
    
    return broadcast
end

-- History tracking
ot_handler.history = {}

function ot_handler.add_to_history(document_id, entry)
    if not ot_handler.history[document_id] then
        ot_handler.history[document_id] = {}
    end
    
    table.insert(ot_handler.history[document_id], entry)
    
    -- Limit history size
    if #ot_handler.history[document_id] > 1000 then
        table.remove(ot_handler.history[document_id], 1)
    end
end

function ot_handler.get_history(document_id, from, to)
    local history = ot_handler.history[document_id] or {}
    local result = {}
    
    from = from or 1
    to = to or #history
    
    for i = from, to do
        if history[i] then
            table.insert(result, history[i])
        end
    end
    
    return result
end

-- Replay operations
function ot_handler.replay(document_id, from_version)
    local doc = ot_handler.documents[document_id]
    if not doc then
        return nil, "Document not found"
    end
    
    local history = ot_handler.history[document_id] or {}
    local ops = {}
    
    for _, entry in ipairs(history) do
        if entry.version > from_version then
            table.insert(ops, entry.operation)
        end
    end
    
    return ot_handler.compose(ops)
end

-- Snapshot
function ot_handler.snapshot(document_id)
    local doc = ot_handler.documents[document_id]
    if not doc then
        return nil, "Document not found"
    end
    
    return {
        document_id = document_id,
        text = doc.text,
        version = doc.version,
        users = doc.users,
        created_at = doc.created_at,
        updated_at = doc.updated_at,
        snapshot_at = os.time()
    }
end

-- Register handlers
local function handle_request()
    local method = ngx.var.request_method
    local uri = ngx.var.uri
    local document_id = ngx.var.arg_doc_id
    local user_id = ngx.var.http_x_user_id
    
    if method == "GET" and uri:match("/documents/") then
        -- Get document
        local doc = ot_handler.documents[document_id]
        if doc then
            ngx.status = 200
            ngx.say(cjson.encode(doc))
        else
            ngx.status = 404
            ngx.say('{"error":"Document not found"}')
        end
        
    elseif method == "POST" and uri:match("/documents/") then
        -- Apply operation
        ngx.req.read_body()
        local body = ngx.req.get_body_data()
        local operation = cjson.decode(body)
        
        local result, err = ot_handler.handle_operation(document_id, user_id, operation)
        if result then
            ngx.status = 200
            ngx.say(cjson.encode(result))
        else
            ngx.status = 400
            ngx.say('{"error":"' .. err .. '"}')
        end
        
    elseif method == "GET" and uri:match("/history/") then
        -- Get history
        local from = tonumber(ngx.var.arg_from) or 1
        local to = tonumber(ngx.var.arg_to)
        
        local history = ot_handler.get_history(document_id, from, to)
        ngx.status = 200
        ngx.say(cjson.encode(history))
        
    elseif method == "GET" and uri:match("/snapshots/") then
        -- Get snapshot
        local snapshot = ot_handler.snapshot(document_id)
        if snapshot then
            ngx.status = 200
            ngx.say(cjson.encode(snapshot))
        else
            ngx.status = 404
            ngx.say('{"error":"Document not found"}')
        end
    end
end

return ot_handler
```

## P34.3 Collaboration Monitoring

### Collaboration Monitoring Dashboard

```bash
#!/bin/bash
# collaboration-monitor.sh - Collaboration monitoring

echo "=== Collaboration Monitoring Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get active documents
get_active_documents() {
    local docs=$(tail -10000 /var/log/nginx/access.log | \
        grep -o '"X-Document-ID":"[^"]*"' | \
        cut -d'"' -f4 | sort -u | wc -l)
    echo "  Active Documents: $docs"
}

# Function: Get active users
get_active_users() {
    local users=$(tail -10000 /var/log/nginx/access.log | \
        grep -o '"X-User-ID":"[^"]*"' | \
        cut -d'"' -f4 | sort -u | wc -l)
    echo "  Active Users: $users"
}

# Function: Get operation rate
get_operation_rate() {
    local ops=$(tail -60 /var/log/nginx/access.log | grep -c "/documents/")
    echo "  Operation Rate: $((ops / 1)) ops/min"
}

# Function: Get presence updates
get_presence_updates() {
    local updates=$(tail -60 /var/log/nginx/access.log | grep -c "/presence/")
    echo "  Presence Updates: $((updates / 1)) updates/min"
}

# Function: Get conflict resolution rate
get_conflict_resolution_rate() {
    local conflicts=$(tail -1000 /var/log/nginx/access.log | grep -c "conflict")
    echo "  Conflict Resolution Rate: $conflicts%"
}

# Main display
while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              COLLABORATION MONITORING DASHBOARD               ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 COLLABORATION STATISTICS:"
    get_active_documents
    get_active_users
    get_operation_rate
    get_presence_updates
    get_conflict_resolution_rate
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx for real-time collaboration applications. Use these techniques to build collaborative editing, shared whiteboards, live coding, and multiplayer experiences.
