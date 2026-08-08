# Part 5: WebSockets, SSE & Inngest Webhooks

## The Target

We're going to transform our secure gateway into a real-time communication hub. By the end of this part, you'll have:

- WebSocket connections with proper upgrade headers
- Server-Sent Events (SSE) streaming without buffering
- Webhook handling for Inngest and third-party services
- Proper timeout configurations for long-running requests
- Connection management for persistent connections
- Complete understanding of different real-time protocols

## The Concept: Real-Time Communication Protocols

Think of different communication methods like different ways to have a conversation:

- **REST (HTTP)**: Like sending letters 📮 - request, wait, response, done
- **WebSockets**: Like a phone call 📞 - persistent two-way conversation
- **SSE (Server-Sent Events)**: Like a radio broadcast 📻 - server pushes updates, client listens
- **Webhooks**: Like a callback 📲 - "Call me when something happens"

Each has different requirements:
- REST: Short-lived, stateless
- WebSockets: Persistent, bidirectional, requires upgrade
- SSE: Persistent, unidirectional (server→client), no upgrade needed
- Webhooks: Incoming HTTP requests from external services

## The Pain Point: Real-Time Connections Fail Behind Proxies

Let's see what happens when real-time connections try to go through a default proxy.

### Step 1: Setup Real-Time Applications

Create the directory structure:

```bash
mkdir -p nginx-series/part-05
cd nginx-series/part-05

# Copy our existing apps
cp -r ../part-04/nextjs-app .
cp -r ../part-04/fastapi-app .
cp -r ../part-04/flask-app .
cp -r ../part-04/auth-api .
cp -r ../part-04/ssl .

# Create WebSocket and SSE apps
mkdir -p websocket-app sse-app webhook-app
```

**File: `websocket-app/requirements.txt`**
```
fastapi==0.104.1
uvicorn[standard]==0.24.0
websockets==12.0
```

**File: `websocket-app/main.py`**
```python
# WebSocket Server with FastAPI
# Demonstrates WebSocket connections behind a proxy

from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Request
from fastapi.responses import HTMLResponse
import asyncio
import json
import time
from typing import List, Dict

app = FastAPI(title="WebSocket Server", version="1.0.0")

# Store active connections
class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []
        self.connection_data: Dict[WebSocket, Dict] = {}

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)
        self.connection_data[websocket] = {
            "connected_at": time.time(),
            "messages_received": 0,
            "messages_sent": 0
        }
        print(f"Client connected. Total: {len(self.active_connections)}")

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)
            if websocket in self.connection_data:
                del self.connection_data[websocket]
        print(f"Client disconnected. Total: {len(self.active_connections)}")

    async def send_personal_message(self, message: str, websocket: WebSocket):
        await websocket.send_text(message)
        if websocket in self.connection_data:
            self.connection_data[websocket]["messages_sent"] += 1

    async def broadcast(self, message: str):
        for connection in self.active_connections:
            try:
                await connection.send_text(message)
                if connection in self.connection_data:
                    self.connection_data[connection]["messages_sent"] += 1
            except Exception as e:
                print(f"Error broadcasting: {e}")

    def get_stats(self):
        return {
            "total_connections": len(self.active_connections),
            "connections": [
                {
                    "id": idx,
                    "connected_at": self.connection_data.get(ws, {}).get("connected_at", 0),
                    "messages_received": self.connection_data.get(ws, {}).get("messages_received", 0),
                    "messages_sent": self.connection_data.get(ws, {}).get("messages_sent", 0)
                }
                for idx, ws in enumerate(self.active_connections)
            ]
        }

manager = ConnectionManager()

# Serve a simple HTML page for testing WebSockets
@app.get("/")
async def get():
    return HTMLResponse("""
    <html>
        <head>
            <title>WebSocket Test</title>
            <style>
                body { font-family: system-ui; max-width: 800px; margin: 0 auto; padding: 20px; }
                #messages { height: 300px; overflow-y: auto; border: 1px solid #ccc; padding: 10px; margin-bottom: 10px; }
                .message { padding: 5px; margin: 5px 0; }
                .sent { background: #e3f2fd; text-align: right; }
                .received { background: #f5f5f5; }
                .system { background: #fff3e0; font-style: italic; }
                input, button { padding: 10px; }
                input { width: 70%; }
                button { width: 25%; }
            </style>
        </head>
        <body>
            <h1>🔄 WebSocket Test</h1>
            <div id="messages"></div>
            <div>
                <input id="messageInput" placeholder="Type a message..." />
                <button id="sendButton">Send</button>
                <button id="connectButton">Connect</button>
                <button id="disconnectButton">Disconnect</button>
            </div>
            <div id="status" style="margin-top: 10px;">Status: Disconnected</div>
            <script>
                let ws = null;
                const messages = document.getElementById('messages');
                const status = document.getElementById('status');
                const messageInput = document.getElementById('messageInput');

                function addMessage(text, type) {
                    const div = document.createElement('div');
                    div.className = `message ${type}`;
                    div.textContent = text;
                    messages.appendChild(div);
                    messages.scrollTop = messages.scrollHeight;
                }

                function setStatus(text) {
                    status.textContent = `Status: ${text}`;
                }

                document.getElementById('connectButton').onclick = () => {
                    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
                    const wsUrl = `${protocol}//${window.location.host}/ws`;
                    ws = new WebSocket(wsUrl);
                    
                    ws.onopen = () => {
                        addMessage('Connected to WebSocket server', 'system');
                        setStatus('Connected');
                    };
                    
                    ws.onmessage = (event) => {
                        addMessage(`Received: ${event.data}`, 'received');
                    };
                    
                    ws.onclose = () => {
                        addMessage('Disconnected from WebSocket server', 'system');
                        setStatus('Disconnected');
                    };
                    
                    ws.onerror = (error) => {
                        addMessage(`Error: ${error}`, 'system');
                        setStatus('Error');
                    };
                };

                document.getElementById('disconnectButton').onclick = () => {
                    if (ws) {
                        ws.close();
                        ws = null;
                    }
                };

                document.getElementById('sendButton').onclick = () => {
                    if (ws && ws.readyState === WebSocket.OPEN) {
                        const message = messageInput.value || 'Hello!';
                        ws.send(message);
                        addMessage(`Sent: ${message}`, 'sent');
                        messageInput.value = '';
                    } else {
                        addMessage('Not connected!', 'system');
                    }
                };
            </script>
        </body>
    </html>
    """)

# WebSocket endpoint
@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        # Send welcome message
        await manager.send_personal_message(f"Welcome! You're connected. ID: {id(websocket)}", websocket)
        
        # Broadcast join message
        await manager.broadcast(f"User {id(websocket)} joined the chat")
        
        while True:
            # Receive message
            data = await websocket.receive_text()
            
            # Update stats
            if websocket in manager.connection_data:
                manager.connection_data[websocket]["messages_received"] += 1
            
            # Echo the message back
            await manager.send_personal_message(f"Echo: {data}", websocket)
            
            # Broadcast to all other clients
            await manager.broadcast(f"User {id(websocket)}: {data}")
            
            # Broadcast stats every 5 messages
            if manager.connection_data[websocket]["messages_received"] % 5 == 0:
                stats = manager.get_stats()
                await manager.broadcast(f"Stats: {json.dumps(stats)}")
                
    except WebSocketDisconnect:
        manager.disconnect(websocket)
        await manager.broadcast(f"User {id(websocket)} left the chat")

# Stats endpoint
@app.get("/stats")
async def get_stats():
    return manager.get_stats()

# Health check
@app.get("/health")
async def health_check():
    return {"status": "healthy", "connections": len(manager.active_connections)}
```

**File: `websocket-app/Dockerfile`**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

EXPOSE 8002

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8002"]
```

**File: `sse-app/requirements.txt`**
```
fastapi==0.104.1
uvicorn[standard]==0.24.0
```

**File: `sse-app/main.py`**
```python
# Server-Sent Events (SSE) Server
# Demonstrates streaming responses behind a proxy

from fastapi import FastAPI, Request
from fastapi.responses import StreamingResponse
from fastapi.responses import HTMLResponse
import asyncio
import json
import time
import random
from typing import AsyncGenerator

app = FastAPI(title="SSE Server", version="1.0.0")

# Serve a simple HTML page for testing SSE
@app.get("/")
async def get():
    return HTMLResponse("""
    <html>
        <head>
            <title>SSE Test</title>
            <style>
                body { font-family: system-ui; max-width: 800px; margin: 0 auto; padding: 20px; }
                #events { height: 400px; overflow-y: auto; border: 1px solid #ccc; padding: 10px; margin-bottom: 10px; }
                .event { padding: 5px; margin: 5px 0; border-left: 3px solid #2196f3; }
                .event-time { color: #666; font-size: 0.8em; }
                .event-data { margin-top: 3px; }
                .ping { border-left-color: #4caf50; }
                .update { border-left-color: #ff9800; }
                .system { border-left-color: #9e9e9e; }
            </style>
        </head>
        <body>
            <h1>📡 Server-Sent Events Test</h1>
            <div id="events"></div>
            <button id="connectButton">Connect</button>
            <button id="disconnectButton">Disconnect</button>
            <div id="status" style="margin-top: 10px;">Status: Disconnected</div>
            <script>
                let eventSource = null;
                const events = document.getElementById('events');
                const status = document.getElementById('status');

                function addEvent(data, type) {
                    const div = document.createElement('div');
                    div.className = `event ${type}`;
                    const time = new Date().toLocaleTimeString();
                    div.innerHTML = `<div class="event-time">${time}</div><div class="event-data">${data}</div>`;
                    events.appendChild(div);
                    events.scrollTop = events.scrollHeight;
                }

                function setStatus(text) {
                    status.textContent = `Status: ${text}`;
                }

                document.getElementById('connectButton').onclick = () => {
                    if (eventSource) {
                        eventSource.close();
                    }
                    eventSource = new EventSource('/stream');
                    
                    eventSource.onopen = () => {
                        addEvent('Connected to SSE stream', 'system');
                        setStatus('Connected');
                    };
                    
                    eventSource.onmessage = (event) => {
                        try {
                            const data = JSON.parse(event.data);
                            addEvent(`Message: ${JSON.stringify(data)}`, 'update');
                        } catch {
                            addEvent(`Raw: ${event.data}`, 'update');
                        }
                    };
                    
                    eventSource.onerror = (error) => {
                        addEvent('Connection error', 'system');
                        setStatus('Error');
                        eventSource.close();
                        eventSource = null;
                    };

                    // Handle specific event types
                    eventSource.addEventListener('ping', (event) => {
                        addEvent(`Ping: ${event.data}`, 'ping');
                    });
                    
                    eventSource.addEventListener('update', (event) => {
                        try {
                            const data = JSON.parse(event.data);
                            addEvent(`Update: ${JSON.stringify(data)}`, 'update');
                        } catch {
                            addEvent(`Update: ${event.data}`, 'update');
                        }
                    });
                };

                document.getElementById('disconnectButton').onclick = () => {
                    if (eventSource) {
                        eventSource.close();
                        eventSource = null;
                        addEvent('Disconnected', 'system');
                        setStatus('Disconnected');
                    }
                };
            </script>
        </body>
    </html>
    """)

async def generate_events() -> AsyncGenerator[str, None]:
    """Generate SSE events"""
    counter = 0
    
    # Send initial connection message
    yield f"event: system\ndata: Connected to SSE stream\n\n"
    
    while True:
        try:
            counter += 1
            
            # Send different types of events
            if counter % 5 == 0:
                # Ping every 5 messages
                yield f"event: ping\ndata: Keep alive #{counter}\n\n"
            
            elif counter % 3 == 0:
                # Update event
                update = {
                    "counter": counter,
                    "timestamp": time.time(),
                    "value": random.randint(1, 100),
                    "message": f"Update #{counter}"
                }
                yield f"event: update\ndata: {json.dumps(update)}\n\n"
            
            else:
                # Regular message
                message = {
                    "counter": counter,
                    "timestamp": time.time(),
                    "status": "active",
                    "random": random.random()
                }
                yield f"data: {json.dumps(message)}\n\n"
            
            await asyncio.sleep(1)
            
        except asyncio.CancelledError:
            yield f"event: system\ndata: Stream ended\n\n"
            break

@app.get("/stream")
async def stream_events():
    """SSE endpoint that streams events"""
    return StreamingResponse(
        generate_events(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",  # Important for Nginx
        }
    )

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.get("/debug")
async def debug_info(request: Request):
    """Debug endpoint showing request headers"""
    return {
        "headers": dict(request.headers),
        "url": str(request.url),
        "method": request.method,
        "client_host": request.client.host if request.client else None,
    }
```

**File: `sse-app/Dockerfile`**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

EXPOSE 8003

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8003"]
```

**File: `webhook-app/requirements.txt`**
```
fastapi==0.104.1
uvicorn[standard]==0.24.0
httpx==0.25.1
```

**File: `webhook-app/main.py`**
```python
# Webhook Receiver
# Demonstrates handling incoming webhooks

from fastapi import FastAPI, Request, HTTPException, BackgroundTasks
from fastapi.responses import JSONResponse
import asyncio
import json
import time
import uuid
from typing import Dict, List, Optional
from datetime import datetime, timedelta
import httpx

app = FastAPI(title="Webhook Receiver", version="1.0.0")

# Store received webhooks
class WebhookStore:
    def __init__(self):
        self.webhooks: List[Dict] = []
        self.processing_tasks: Dict[str, Dict] = {}
        self.failed_webhooks: List[Dict] = []

    def add_webhook(self, data: Dict, source: str) -> str:
        """Store a received webhook"""
        webhook_id = str(uuid.uuid4())
        entry = {
            "id": webhook_id,
            "source": source,
            "data": data,
            "received_at": time.time(),
            "processed": False,
            "processing_time": None,
            "status": "pending"
        }
        self.webhooks.append(entry)
        return webhook_id

    def mark_processed(self, webhook_id: str):
        """Mark a webhook as processed"""
        for webhook in self.webhooks:
            if webhook["id"] == webhook_id:
                webhook["processed"] = True
                webhook["status"] = "completed"
                webhook["processing_time"] = time.time() - webhook["received_at"]
                return True
        return False

    def mark_failed(self, webhook_id: str, error: str):
        """Mark a webhook as failed"""
        for webhook in self.webhooks:
            if webhook["id"] == webhook_id:
                webhook["status"] = "failed"
                webhook["error"] = error
                self.failed_webhooks.append(webhook)
                return True
        return False

    def get_webhooks(self, limit: int = 50) -> List[Dict]:
        """Get recent webhooks"""
        return sorted(self.webhooks, key=lambda x: x["received_at"], reverse=True)[:limit]

    def get_stats(self) -> Dict:
        """Get webhook statistics"""
        total = len(self.webhooks)
        processed = len([w for w in self.webhooks if w.get("processed")])
        failed = len([w for w in self.webhooks if w.get("status") == "failed"])
        pending = total - processed - failed
        
        return {
            "total": total,
            "processed": processed,
            "pending": pending,
            "failed": failed,
            "recent": self.get_webhooks(5)
        }

store = WebhookStore()

# Inngest Webhook endpoint
@app.post("/inngest")
async def inngest_webhook(request: Request, background_tasks: BackgroundTasks):
    """
    Inngest webhook receiver
    Handles event ingestion from Inngest
    """
    try:
        # Parse the webhook payload
        payload = await request.json()
        
        # Log the webhook
        print(f"Received Inngest webhook: {json.dumps(payload, indent=2)[:200]}...")
        
        # Store the webhook
        webhook_id = store.add_webhook(payload, "inngest")
        
        # Process in background to avoid timeouts
        background_tasks.add_task(process_webhook, webhook_id, payload, "inngest")
        
        # Acknowledge receipt
        return JSONResponse(
            status_code=200,
            content={
                "status": "received",
                "id": webhook_id,
                "message": "Webhook received and queued for processing"
            }
        )
        
    except Exception as e:
        print(f"Error processing Inngest webhook: {e}")
        raise HTTPException(status_code=400, detail=str(e))

# Generic webhook endpoint
@app.post("/generic")
async def generic_webhook(request: Request, background_tasks: BackgroundTasks):
    """Generic webhook receiver for any webhook"""
    try:
        # Try to parse as JSON, otherwise treat as raw
        try:
            payload = await request.json()
        except:
            payload = {"raw": await request.body()}
        
        # Get webhook source from headers
        source = request.headers.get("X-Webhook-Source", "generic")
        
        # Store the webhook
        webhook_id = store.add_webhook(payload, source)
        
        # Process in background
        background_tasks.add_task(process_webhook, webhook_id, payload, source)
        
        return JSONResponse(
            status_code=200,
            content={
                "status": "received",
                "id": webhook_id,
                "source": source
            }
        )
        
    except Exception as e:
        print(f"Error processing webhook: {e}")
        raise HTTPException(status_code=400, detail=str(e))

async def process_webhook(webhook_id: str, payload: Dict, source: str):
    """Process a webhook in the background"""
    try:
        print(f"Processing webhook {webhook_id} from {source}")
        
        # Simulate processing time
        await asyncio.sleep(0.5)
        
        # Example: Send confirmation webhook
        if source == "inngest":
            # Inngest expects a callback or confirmation
            # This is where you'd integrate with your Inngest functions
            print(f"Processing Inngest event: {payload.get('event', {}).get('name', 'unknown')}")
        
        # Mark as processed
        store.mark_processed(webhook_id)
        print(f"Webhook {webhook_id} processed successfully")
        
    except Exception as e:
        print(f"Failed to process webhook {webhook_id}: {e}")
        store.mark_failed(webhook_id, str(e))

# Webhook status endpoint
@app.get("/webhooks")
async def get_webhooks(limit: int = 50):
    """Get recent webhooks"""
    return {
        "webhooks": store.get_webhooks(limit),
        "stats": store.get_stats()
    }

# Webhook stats endpoint
@app.get("/stats")
async def get_webhook_stats():
    """Get webhook statistics"""
    return store.get_stats()

# Health check
@app.get("/health")
async def health_check():
    return {"status": "healthy", "webhooks": len(store.webhooks)}

# Debug endpoint
@app.get("/debug")
async def debug_info(request: Request):
    """Debug endpoint showing request information"""
    return {
        "headers": dict(request.headers),
        "url": str(request.url),
        "method": request.method,
        "client_host": request.client.host if request.client else None,
    }
```

**File: `webhook-app/Dockerfile`**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

EXPOSE 8004

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8004"]
```

### Step 2: The Broken Setup (Real-Time Misconfiguration)

**File: `docker-compose.yml`**
```yaml
version: '3.8'

services:
  nextjs:
    build:
      context: ./nextjs-app
      dockerfile: Dockerfile
    container_name: nextjs-app
    ports:
      - "3000:3000"
    networks:
      - app-network

  fastapi:
    build:
      context: ./fastapi-app
      dockerfile: Dockerfile
    container_name: fastapi-api
    ports:
      - "8000:8000"
    networks:
      - app-network

  auth-api:
    build:
      context: ./auth-api
      dockerfile: Dockerfile
    container_name: auth-api
    ports:
      - "8001:8001"
    networks:
      - app-network

  websocket:
    build:
      context: ./websocket-app
      dockerfile: Dockerfile
    container_name: websocket-app
    ports:
      - "8002:8002"
    networks:
      - app-network

  sse:
    build:
      context: ./sse-app
      dockerfile: Dockerfile
    container_name: sse-app
    ports:
      - "8003:8003"
    networks:
      - app-network

  webhook:
    build:
      context: ./webhook-app
      dockerfile: Dockerfile
    container_name: webhook-app
    ports:
      - "8004:8004"
    networks:
      - app-network

  nginx:
    image: nginx:1.27-alpine
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
      - ./logs:/var/log/nginx
    depends_on:
      - nextjs
      - fastapi
      - auth-api
      - websocket
      - sse
      - webhook
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

**File: `nginx.conf` (INTENTIONALLY BROKEN)**
```nginx
# This configuration has multiple problems:
# 1. WebSockets: Missing Upgrade headers
# 2. WebSockets: Connection: upgrade missing
# 3. SSE: Buffering enabled (breaks streaming)
# 4. SSE: Missing X-Accel-Buffering header
# 5. Webhooks: Timeout issues
# 6. Webhooks: Missing request body handling

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    sendfile on;
    keepalive_timeout 65;

    # Rate limiting (from Part 4)
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=60r/m;
    limit_req_zone $binary_remote_addr zone=webhook_limit:10m rate=30r/m;

    upstream auth_backend {
        server auth-api:8001;
        keepalive 32;
    }

    upstream api_backend {
        server fastapi:8000;
        keepalive 32;
    }

    upstream websocket_backend {
        server websocket:8002;
        keepalive 32;
    }

    upstream sse_backend {
        server sse:8003;
        keepalive 32;
    }

    upstream webhook_backend {
        server webhook:8004;
        keepalive 32;
    }

    upstream frontend_backend {
        server nextjs:3000;
    }

    server {
        listen 443 ssl http2;
        server_name localhost;

        ssl_certificate /etc/nginx/ssl/localhost.crt;
        ssl_certificate_key /etc/nginx/ssl/localhost.key;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
        ssl_prefer_server_ciphers off;

        # Security headers
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;

        # Root - frontend
        location / {
            proxy_pass http://frontend_backend;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # API - FastAPI
        location /api/ {
            limit_req zone=api_limit burst=10 nodelay;
            
            proxy_pass http://api_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Authorization $http_authorization;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # Auth - Authentication API
        location /auth/ {
            proxy_pass http://auth_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Authorization $http_authorization;
            proxy_set_header Cookie $http_cookie;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # WebSocket - PROBLEM: Missing upgrade headers
        location /ws/ {
            proxy_pass http://websocket_backend/;
            
            # PROBLEM: Missing HTTP 1.1 upgrade
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # PROBLEM: Connection: upgrade is missing
            # PROBLEM: Upgrade header is missing
            # PROBLEM: No timeout configuration

            proxy_http_version 1.1;  # This is set, but upgrade headers are missing
        }

        # SSE - PROBLEM: Buffering enabled
        location /sse/ {
            proxy_pass http://sse_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # PROBLEM: proxy_buffering is on by default
            # PROBLEM: Missing X-Accel-Buffering header
            # PROBLEM: Missing timeout configuration

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # Webhooks - PROBLEM: Timeouts too low
        location /webhook/ {
            proxy_pass http://webhook_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # PROBLEM: Default timeouts (60s) may be too short
            # PROBLEM: Large request bodies might be rejected
            # PROBLEM: No buffering configuration for large payloads

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
    }

    # HTTP redirect to HTTPS
    server {
        listen 80;
        server_name localhost;
        return 301 https://$host$request_uri;
    }
}
```

### Step 3: Run and Observe the Failures

```bash
# Start the services
docker compose up -d

# Wait for everything to start
sleep 15

# Test 1: WebSocket connection (will fail)
echo "Testing WebSocket connection..."
curl -k -N -H "Connection: Upgrade" \
    -H "Upgrade: websocket" \
    -H "Sec-WebSocket-Key: x3JJHMbDL1EzLkh9GBhXDw==" \
    -H "Sec-WebSocket-Version: 13" \
    https://localhost/ws/ 2>&1 | head -n 10
# Will fail with 400 Bad Request or connection issues

# Test 2: SSE connection (will buffer)
echo "Testing SSE connection..."
curl -k -N https://localhost/sse/stream &
SSE_PID=$!
sleep 5
echo "Killing after 5 seconds - likely didn't receive events in real-time"
kill $SSE_PID 2>/dev/null

# Test 3: Webhook with long processing
echo "Testing webhook with long processing..."
curl -k -X POST https://localhost/webhook/inngest \
    -H "Content-Type: application/json" \
    -d '{"event": {"name": "test", "data": {"message": "Hello"}}}' \
    -w "\n\nHTTP Status: %{http_code}\n"

# Test 4: Check for timeouts
echo "Testing timeout handling..."
timeout 10 curl -k -X POST https://localhost/webhook/inngest \
    -H "Content-Type: application/json" \
    -d '{"event": {"name": "long", "data": {"simulate_delay": 30}}}' \
    -w "\n\nHTTP Status: %{http_code}\n"
```

### Step 4: Understanding the Failures

**Problem 1: WebSocket Upgrade Fails**
- WebSocket connections require HTTP/1.1 with Upgrade headers
- Without `Connection: upgrade` and `Upgrade: websocket`, the connection fails
- Nginx doesn't know to keep the connection open

**Problem 2: SSE Streaming Buffered**
- By default, Nginx buffers responses
- This breaks SSE streaming because events aren't sent in real-time
- Each event sits in the buffer until it fills up

**Problem 3: Webhook Timeouts**
- Default timeout (60s) too short for long-running operations
- Webhooks from services like Inngest may time out
- Large webhook payloads might be rejected

### Step 5: The Fix - Complete Real-Time Configuration

**File: `nginx.conf` (FIXED)**
```nginx
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    sendfile on;
    keepalive_timeout 65;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=60r/m;
    limit_req_zone $binary_remote_addr zone=webhook_limit:10m rate=30r/m;
    limit_req_zone $binary_remote_addr zone=ws_limit:10m rate=30r/m;

    # Upstream groups
    upstream auth_backend {
        server auth-api:8001;
        keepalive 32;
    }

    upstream api_backend {
        server fastapi:8000;
        keepalive 32;
    }

    upstream websocket_backend {
        server websocket:8002;
        keepalive 32;
    }

    upstream sse_backend {
        server sse:8003;
        keepalive 32;
    }

    upstream webhook_backend {
        server webhook:8004;
        keepalive 32;
    }

    upstream frontend_backend {
        server nextjs:3000;
    }

    server {
        listen 443 ssl http2;
        server_name localhost;

        ssl_certificate /etc/nginx/ssl/localhost.crt;
        ssl_certificate_key /etc/nginx/ssl/localhost.key;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305';
        ssl_prefer_server_ciphers off;

        # Security headers
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        add_header X-XSS-Protection "1; mode=block" always;

        # Root - frontend
        location / {
            proxy_pass http://frontend_backend;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # API - FastAPI
        location /api/ {
            limit_req zone=api_limit burst=10 nodelay;
            
            proxy_pass http://api_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Authorization $http_authorization;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # Auth - Authentication API
        location /auth/ {
            proxy_pass http://auth_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Authorization $http_authorization;
            proxy_set_header Cookie $http_cookie;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # WebSocket - FIXED with proper upgrade headers
        location /ws/ {
            limit_req zone=ws_limit burst=5 nodelay;
            
            proxy_pass http://websocket_backend/;
            
            # WebSocket specific headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # FIXED: Required for WebSocket upgrade
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            # FIXED: Longer timeouts for WebSocket connections
            proxy_read_timeout 300s;
            proxy_connect_timeout 75s;
            
            # Disable buffering for WebSocket
            proxy_buffering off;
        }

        # SSE - FIXED with buffering disabled
        location /sse/ {
            # SSE doesn't use upgrade, but needs persistent connection
            proxy_pass http://sse_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # FIXED: Disable buffering for SSE
            proxy_buffering off;
            
            # FIXED: Disable request buffering
            proxy_request_buffering off;
            
            # FIXED: Longer timeouts for streaming
            proxy_read_timeout 600s;
            proxy_connect_timeout 75s;
            
            # FIXED: Add header to tell proxy not to buffer
            proxy_set_header X-Accel-Buffering no;
            
            # FIXED: Keep connection alive
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # FIXED: Cache control for SSE
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            add_header Pragma "no-cache";
        }

        # Webhooks - FIXED with proper timeouts and buffering
        location /webhook/ {
            limit_req zone=webhook_limit burst=5 nodelay;
            
            proxy_pass http://webhook_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Authorization $http_authorization;
            
            # FIXED: Long timeouts for webhook processing
            proxy_read_timeout 300s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 300s;
            
            # FIXED: Large request body for webhook payloads
            client_max_body_size 10M;
            client_body_buffer_size 128k;
            
            # FIXED: Buffering for large webhook payloads
            proxy_buffering on;
            proxy_buffer_size 128k;
            proxy_buffers 4 256k;
            proxy_busy_buffers_size 256k;
            
            # FIXED: Allow for retry headers
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
            proxy_next_upstream_tries 2;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
    }

    # HTTP redirect to HTTPS
    server {
        listen 80;
        server_name localhost;
        return 301 https://$host$request_uri;
    }
}
```

### Step 6: Test the Fixed Configuration

```bash
# Reload Nginx with the fixed configuration
docker exec nginx-proxy nginx -t
docker exec nginx-proxy nginx -s reload

# Wait a moment for the reload
sleep 2

# Test 1: WebSocket connection (should work)
echo "Testing WebSocket connection..."
curl -k -N -H "Connection: Upgrade" \
    -H "Upgrade: websocket" \
    -H "Sec-WebSocket-Key: x3JJHMbDL1EzLkh9GBhXDw==" \
    -H "Sec-WebSocket-Version: 13" \
    https://localhost/ws/ 2>&1 | head -n 20
# Should show WebSocket upgrade response

# Test 2: SSE streaming (should show real-time events)
echo "Testing SSE streaming..."
curl -k -N https://localhost/sse/stream &
SSE_PID=$!
sleep 3
echo "Should have received multiple events in real-time"
kill $SSE_PID 2>/dev/null

# Test 3: Webhook with long processing
echo "Testing webhook with long processing..."
curl -k -X POST https://localhost/webhook/inngest \
    -H "Content-Type: application/json" \
    -d '{"event": {"name": "test", "data": {"message": "Hello"}}}' \
    | python -m json.tool

# Test 4: Webhook status check
sleep 2
curl -k -s https://localhost/webhook/webhooks?limit=5 \
    | python -m json.tool

# Test 5: Verify WebSocket headers are forwarded
curl -k -s https://localhost/ws/health \
    | python -m json.tool
# Should show the WebSocket service is healthy

# Test 6: SSE debug - verify headers
curl -k -s https://localhost/sse/debug \
    | python -m json.tool
# Should show X-Accel-Buffering: no
```

### Step 7: Advanced - WebSocket and SSE Performance Tuning

**File: `nginx-websocket-perf.conf`**
```nginx
# WebSocket Performance Tuning
# Add these to your WebSocket location

location /ws/ {
    proxy_pass http://websocket_backend/;
    
    # Connection upgrade headers
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    
    # FIXED: Disable all buffering
    proxy_buffering off;
    proxy_cache off;
    
    # FIXED: Optimize for real-time
    proxy_read_timeout 600s;
    proxy_connect_timeout 75s;
    proxy_send_timeout 600s;
    
    # FIXED: Connection keepalive
    proxy_set_header Connection "upgrade";
    keepalive_timeout 600s;
    
    # FIXED: Header forwarding
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    
    # FIXED: WebSocket-specific rate limiting
    limit_req zone=ws_limit burst=5 nodelay;
    limit_conn_limit per_ip 10;
    
    # FIXED: Error handling for WebSocket
    proxy_next_upstream error timeout invalid_header http_500 http_502;
    proxy_next_upstream_tries 2;
    
    # FIXED: Access logs for debugging
    access_log /var/log/nginx/websocket-access.log;
    error_log /var/log/nginx/websocket-error.log;
}
```

### Step 8: Inngest Webhook Integration

Inngest is a serverless event-driven platform. Here's how to properly handle Inngest webhooks:

**File: `nginx-inngest.conf`**
```nginx
# Inngest Webhook Configuration
# Optimized for Inngest webhook processing

location /inngest/ {
    # Webhook rate limiting
    limit_req zone=webhook_limit burst=10 nodelay;
    
    proxy_pass http://webhook_backend/;
    
    # Inngest-specific headers
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    
    # Inngest expects 200 OK quickly
    proxy_read_timeout 300s;
    proxy_connect_timeout 75s;
    proxy_send_timeout 300s;
    
    # Inngest sends large events (up to 1MB)
    client_max_body_size 1M;
    client_body_buffer_size 128k;
    
    # Buffer the request body
    proxy_buffering on;
    proxy_buffer_size 128k;
    proxy_buffers 4 256k;
    proxy_busy_buffers_size 256k;
    
    # Inngest-specific headers
    proxy_set_header X-Inngest-Source "webhook";
    
    # Enable retries for Inngest
    proxy_next_upstream error timeout http_500 http_502 http_503 http_504;
    proxy_next_upstream_tries 3;
    proxy_next_upstream_timeout 30s;
    
    # Keep connection alive
    proxy_http_version 1.1;
    proxy_set_header Connection "";
}
```

### Step 9: Comprehensive Timeout Configuration

**File: `nginx-timeouts.conf`**
```nginx
# Timeout Configuration Reference
# Place these in the http block for global settings

# Client timeouts
client_body_timeout 60s;        # Time to read client body
client_header_timeout 60s;      # Time to read client headers
send_timeout 60s;               # Time to send response to client

# Proxy timeouts
proxy_connect_timeout 75s;      # Time to connect to upstream
proxy_read_timeout 60s;         # Time to read from upstream
proxy_send_timeout 60s;         # Time to send to upstream

# Connection timeouts
keepalive_timeout 65s;          # Time to keep connection open
keepalive_requests 100;         # Max requests per connection

# Specific timeout overrides
location /ws/ {
    # WebSockets need long timeouts
    proxy_read_timeout 600s;
    proxy_connect_timeout 75s;
    proxy_send_timeout 600s;
    
    keepalive_timeout 600s;
}

location /sse/ {
    # SSE needs long timeouts but not as long as WebSockets
    proxy_read_timeout 300s;
    proxy_connect_timeout 75s;
    proxy_send_timeout 300s;
}

location /webhook/ {
    # Webhooks can have moderate timeouts
    proxy_read_timeout 120s;
    proxy_connect_timeout 75s;
    proxy_send_timeout 120s;
}
```

## Verification Checklist

Before moving on, verify you've mastered real-time connections:

### ✅ Check 1: WebSocket Connection Works
```bash
# Test WebSocket upgrade
curl -k -I -H "Connection: Upgrade" \
    -H "Upgrade: websocket" \
    https://localhost/ws/
# Should return 101 Switching Protocols
```

### ✅ Check 2: SSE Streaming Works
```bash
# Test SSE streaming
curl -k -N https://localhost/sse/stream &
sleep 3
# Should see real-time events streaming
pkill -f "curl.*sse"
```

### ✅ Check 3: Webhook Endpoint Works
```bash
# Test webhook reception
curl -k -X POST https://localhost/webhook/inngest \
    -H "Content-Type: application/json" \
    -d '{"event": {"name": "test", "data": {"message": "Hello"}}}'
# Should return 200 OK with ID
```

### ✅ Check 4: WebSocket Headers Forwarded
```bash
# Check WebSocket headers
curl -k -s https://localhost/ws/health | python -m json.tool
# Should show "status": "healthy"
```

### ✅ Check 5: SSE Headers Correct
```bash
# Check SSE headers
curl -k -I https://localhost/sse/stream
# Should show:
# Cache-Control: no-cache
# X-Accel-Buffering: no
```

### ✅ Check 6: Webhook Processing Works
```bash
# Check webhook storage
curl -k -s https://localhost/webhook/webhooks | python -m json.tool
# Should show recent webhooks
```

## Common Pitfalls and Solutions

### Pitfall 1: WebSocket Connection Drops Immediately

**Symptom:** WebSocket connects then disconnects

**Wrong:**
```nginx
location /ws/ {
    proxy_pass http://websocket_backend/;
    # Missing upgrade headers
}
```

**Right:**
```nginx
location /ws/ {
    proxy_pass http://websocket_backend/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
```

### Pitfall 2: SSE Events Not Streaming

**Symptom:** SSE works but events are delayed

**Wrong:**
```nginx
location /sse/ {
    proxy_pass http://sse_backend/;
    # Buffering is on by default
}
```

**Right:**
```nginx
location /sse/ {
    proxy_pass http://sse_backend/;
    proxy_buffering off;
    proxy_set_header X-Accel-Buffering no;
}
```

### Pitfall 3: Webhooks Timing Out

**Symptom:** Webhook requests return 504 Gateway Timeout

**Wrong:**
```nginx
location /webhook/ {
    proxy_pass http://webhook_backend/;
    # Default 60s timeout
}
```

**Right:**
```nginx
location /webhook/ {
    proxy_pass http://webhook_backend/;
    proxy_read_timeout 300s;
    proxy_connect_timeout 75s;
}
```

### Pitfall 4: Large Webhook Payloads Rejected

**Symptom:** Webhook returns 413 Request Entity Too Large

**Wrong:**
```nginx
location /webhook/ {
    proxy_pass http://webhook_backend/;
    # Default 1MB limit
}
```

**Right:**
```nginx
location /webhook/ {
    proxy_pass http://webhook_backend/;
    client_max_body_size 10M;
    client_body_buffer_size 128k;
}
```

## What You've Learned

By completing Part 5, you can now:

- ✅ Configure WebSocket connections with upgrade headers
- ✅ Set up Server-Sent Events (SSE) with buffering disabled
- ✅ Handle webhooks with proper timeouts
- ✅ Configure large request bodies for webhooks
- ✅ Understand the difference between WebSockets and SSE
- ✅ Implement proper timeout configurations
- ✅ Debug real-time connection issues
- ✅ Monitor WebSocket connections
- ✅ Process webhooks in the background
- ✅ Set up Inngest webhook integration

## Reference: Real-Time Protocol Comparison

| Feature | WebSocket | SSE | Webhooks |
|---------|-----------|-----|----------|
| **Direction** | Bidirectional | Server→Client | External→Server |
| **Protocol** | WS/WSS | HTTP/HTTPS | HTTP/HTTPS |
| **Upgrade Required** | Yes | No | No |
| **Nginx Key Settings** | Upgrade headers | proxy_buffering off | Timeouts, body size |
| **Connection Type** | Persistent | Persistent | Short-lived |
| **Typical Use** | Chat, gaming | Notifications, updates | Events, integrations |
| **Timeout** | Very long (5-10 min) | Long (5 min) | Medium (2 min) |
| **Reconnection** | Manual | Automatic (EventSource) | Service dependent |

## Next Steps

**Part 6: Caching, Compression & Performance** builds on our real-time gateway. You'll learn:

- Static asset caching
- Proxy caching for API responses
- Micro-caching for high-traffic endpoints
- Gzip compression
- Cache invalidation strategies
- Performance optimization techniques

Your gateway is real-time and intelligent. Now let's make it fast.
