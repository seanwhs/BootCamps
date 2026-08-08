# Appendix C: Complete Docker Compose Environment

## The Target

This appendix provides the complete Docker Compose environment used throughout the series. Everything is self-contained, reproducible, and ready to run. You can use this as a template for your own projects or as a learning playground.

## C.1 Project Structure

```
nginx-series/
├── part-10/
│   ├── docker-compose.yml          # Main compose file
│   ├── nginx.conf                  # Complete Nginx configuration
│   ├── deploy.sh                   # Deployment script
│   ├── monitor.sh                  # Monitoring script
│   ├── validate.sh                 # Validation script
│   ├── ssl/                        # SSL certificates
│   │   ├── localhost.crt
│   │   └── localhost.key
│   ├── logs/                       # Log files (mounted)
│   ├── cache/                      # Cache directory (mounted)
│   ├── nextjs-app/                 # Next.js frontend
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   ├── next.config.js
│   │   └── pages/
│   │       └── index.js
│   ├── fastapi-blue/               # API v1
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   └── main.py
│   ├── fastapi-green/              # API v2
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   └── main.py
│   ├── auth-api/                   # Authentication service
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   └── main.py
│   ├── websocket-app/              # WebSocket server
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   └── main.py
│   ├── sse-app/                    # SSE server
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   └── main.py
│   └── webhook-app/                # Webhook receiver
│       ├── Dockerfile
│       ├── requirements.txt
│       └── main.py
```

## C.2 Complete docker-compose.yml

**File: `docker-compose.yml`**

```yaml
version: '3.8'

# ============================================================================
# Production Full-Stack Gateway
# Complete Docker Compose environment for the Nginx series
# ============================================================================

services:
  # --------------------------------------------------------------------------
  # Next.js Frontend Service
  # --------------------------------------------------------------------------
  nextjs:
    build:
      context: ./nextjs-app
      dockerfile: Dockerfile
    container_name: nextjs-app
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - NEXT_PUBLIC_API_URL=https://localhost/api
      - NEXT_PUBLIC_WS_URL=wss://localhost/ws
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:3000"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # --------------------------------------------------------------------------
  # FastAPI Blue Instance (Version 1.0.0)
  # --------------------------------------------------------------------------
  fastapi-blue:
    build:
      context: ./fastapi-blue
      dockerfile: Dockerfile
    container_name: fastapi-blue
    ports:
      - "8000:8000"
    environment:
      - HOSTNAME=blue-instance
      - VERSION=1.0.0
      - PYTHONUNBUFFERED=1
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # --------------------------------------------------------------------------
  # FastAPI Green Instance (Version 2.0.0)
  # --------------------------------------------------------------------------
  fastapi-green:
    build:
      context: ./fastapi-green
      dockerfile: Dockerfile
    container_name: fastapi-green
    ports:
      - "8001:8000"
    environment:
      - HOSTNAME=green-instance
      - VERSION=2.0.0
      - PYTHONUNBUFFERED=1
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # --------------------------------------------------------------------------
  # Authentication API Service
  # --------------------------------------------------------------------------
  auth-api:
    build:
      context: ./auth-api
      dockerfile: Dockerfile
    container_name: auth-api
    ports:
      - "8002:8001"
    environment:
      - SECRET_KEY=your-secret-key-change-in-production
      - HOSTNAME=auth-instance
      - PYTHONUNBUFFERED=1
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8001/health"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # --------------------------------------------------------------------------
  # WebSocket Server
  # --------------------------------------------------------------------------
  websocket:
    build:
      context: ./websocket-app
      dockerfile: Dockerfile
    container_name: websocket-app
    ports:
      - "8003:8002"
    environment:
      - HOSTNAME=websocket-instance
      - PYTHONUNBUFFERED=1
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8002/health"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # --------------------------------------------------------------------------
  # Server-Sent Events (SSE) Server
  # --------------------------------------------------------------------------
  sse:
    build:
      context: ./sse-app
      dockerfile: Dockerfile
    container_name: sse-app
    ports:
      - "8004:8003"
    environment:
      - HOSTNAME=sse-instance
      - PYTHONUNBUFFERED=1
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8003/health"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # --------------------------------------------------------------------------
  # Webhook Receiver
  # --------------------------------------------------------------------------
  webhook:
    build:
      context: ./webhook-app
      dockerfile: Dockerfile
    container_name: webhook-app
    ports:
      - "8005:8004"
    environment:
      - HOSTNAME=webhook-instance
      - PYTHONUNBUFFERED=1
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8004/health"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # --------------------------------------------------------------------------
  # Nginx Gateway
  # --------------------------------------------------------------------------
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
      - ./cache:/var/cache/nginx
    depends_on:
      - nextjs
      - fastapi-blue
      - fastapi-green
      - auth-api
      - websocket
      - sse
      - webhook
    networks:
      - app-network
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "https://localhost/nginx-health"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 30s

# ============================================================================
# Networks
# ============================================================================
networks:
  app-network:
    driver: bridge
    name: nginx-app-network

# ============================================================================
# Volumes
# ============================================================================
volumes:
  logs:
    driver: local
  cache:
    driver: local
```

## C.3 Application Source Files

### C.3.1 Next.js Application

**File: `nextjs-app/Dockerfile`**

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

EXPOSE 3000

CMD ["npm", "start"]
```

**File: `nextjs-app/package.json`**

```json
{
  "name": "nextjs-frontend",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start"
  },
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  }
}
```

**File: `nextjs-app/next.config.js`**

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  trailingSlash: true,
  output: 'standalone',
  productionBrowserSourceMaps: false,
  poweredByHeader: false,
  compress: true,
}

module.exports = nextConfig
```

**File: `nextjs-app/pages/index.js`**

```javascript
import { useEffect, useState } from 'react';

export default function Home() {
  const [apiData, setApiData] = useState(null);
  const [wsStatus, setWsStatus] = useState('Disconnected');
  const [sseData, setSseData] = useState([]);

  // Fetch API data
  useEffect(() => {
    fetch('/api/')
      .then(res => res.json())
      .then(data => setApiData(data))
      .catch(console.error);
  }, []);

  // WebSocket connection
  useEffect(() => {
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const ws = new WebSocket(`${protocol}//${window.location.host}/ws/`);

    ws.onopen = () => setWsStatus('Connected');
    ws.onclose = () => setWsStatus('Disconnected');
    ws.onerror = () => setWsStatus('Error');

    return () => ws.close();
  }, []);

  // SSE connection
  useEffect(() => {
    const eventSource = new EventSource('/sse/stream');

    eventSource.onmessage = (event) => {
      setSseData(prev => [...prev.slice(-4), event.data]);
    };

    return () => eventSource.close();
  }, []);

  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      minHeight: '100vh',
      fontFamily: 'system-ui, sans-serif',
      padding: '20px',
      background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
      color: 'white'
    }}>
      <h1 style={{ fontSize: '3rem', marginBottom: '1rem' }}>
        🚀 Production Gateway
      </h1>
      
      <div style={{
        background: 'rgba(255,255,255,0.1)',
        borderRadius: '12px',
        padding: '20px',
        maxWidth: '600px',
        width: '100%',
        backdropFilter: 'blur(10px)'
      }}>
        <h2>API Status</h2>
        <pre style={{ background: 'rgba(0,0,0,0.3)', padding: '10px', borderRadius: '4px' }}>
          {apiData ? JSON.stringify(apiData, null, 2) : 'Loading...'}
        </pre>
      </div>

      <div style={{
        display: 'grid',
        gridTemplateColumns: '1fr 1fr 1fr',
        gap: '20px',
        marginTop: '20px',
        width: '100%',
        maxWidth: '600px'
      }}>
        <div style={{ background: 'rgba(255,255,255,0.1)', padding: '15px', borderRadius: '8px' }}>
          <h3>WebSocket</h3>
          <p>Status: {wsStatus}</p>
        </div>
        
        <div style={{ background: 'rgba(255,255,255,0.1)', padding: '15px', borderRadius: '8px' }}>
          <h3>SSE</h3>
          <p>Messages: {sseData.length}</p>
          <div style={{ fontSize: '0.8rem', maxHeight: '60px', overflow: 'auto' }}>
            {sseData.slice(-3).map((msg, i) => (
              <div key={i}>📡 {msg.slice(0, 30)}</div>
            ))}
          </div>
        </div>

        <div style={{ background: 'rgba(255,255,255,0.1)', padding: '15px', borderRadius: '8px' }}>
          <h3>Security</h3>
          <p>🔒 HTTPS</p>
          <p>🛡️ Headers Active</p>
        </div>
      </div>

      <div style={{ marginTop: '30px', fontSize: '0.9rem', opacity: 0.7 }}>
        <p>Try the API: <code>/api/</code></p>
        <p>WebSocket: <code>/ws/</code></p>
        <p>SSE: <code>/sse/</code></p>
      </div>
    </div>
  );
}
```

### C.3.2 FastAPI Blue (Version 1)

**File: `fastapi-blue/Dockerfile`**

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**File: `fastapi-blue/requirements.txt`**

```
fastapi==0.104.1
uvicorn[standard]==0.24.0
```

**File: `fastapi-blue/main.py`**

```python
from fastapi import FastAPI, Request
import time
import os
import uuid
import json
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Blue Instance", version="1.0.0")

@app.middleware("http")
async def log_requests(request: Request, call_next):
    request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
    start_time = time.time()
    
    response = await call_next(request)
    
    duration = time.time() - start_time
    logger.info(json.dumps({
        "type": "request_complete",
        "request_id": request_id,
        "path": request.url.path,
        "status": response.status_code,
        "duration_ms": duration * 1000
    }))
    
    response.headers["X-Request-ID"] = request_id
    response.headers["X-Response-Time"] = f"{duration:.3f}s"
    
    return response

@app.get("/")
async def root(request: Request):
    return {
        "instance": "blue",
        "version": "1.0.0",
        "color": "blue",
        "timestamp": time.time(),
        "hostname": os.environ.get("HOSTNAME", "unknown"),
        "request_id": request.headers.get("X-Request-ID", "unknown")
    }

@app.get("/health")
async def health():
    return {"status": "healthy", "instance": "blue"}

@app.get("/debug/headers")
async def debug_headers(request: Request):
    return {"headers": dict(request.headers)}
```

### C.3.3 FastAPI Green (Version 2)

**File: `fastapi-green/Dockerfile`**

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**File: `fastapi-green/requirements.txt`**

```
fastapi==0.104.1
uvicorn[standard]==0.24.0
```

**File: `fastapi-green/main.py`**

```python
from fastapi import FastAPI, Request
import time
import os
import uuid
import json
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Green Instance", version="2.0.0")

@app.middleware("http")
async def log_requests(request: Request, call_next):
    request_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
    start_time = time.time()
    
    response = await call_next(request)
    
    duration = time.time() - start_time
    logger.info(json.dumps({
        "type": "request_complete",
        "request_id": request_id,
        "path": request.url.path,
        "status": response.status_code,
        "duration_ms": duration * 1000
    }))
    
    response.headers["X-Request-ID"] = request_id
    response.headers["X-Response-Time"] = f"{duration:.3f}s"
    
    return response

@app.get("/")
async def root(request: Request):
    return {
        "instance": "green",
        "version": "2.0.0",
        "color": "green",
        "timestamp": time.time(),
        "hostname": os.environ.get("HOSTNAME", "unknown"),
        "request_id": request.headers.get("X-Request-ID", "unknown")
    }

@app.get("/health")
async def health():
    return {"status": "healthy", "instance": "green"}
```

### C.3.4 Authentication API

**File: `auth-api/Dockerfile`**

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

EXPOSE 8001

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001"]
```

**File: `auth-api/requirements.txt`**

```
fastapi==0.104.1
uvicorn[standard]==0.24.0
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6
```

**File: `auth-api/main.py`**

```python
from fastapi import FastAPI, HTTPException, Depends, status, Request
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from typing import Optional
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext

SECRET_KEY = "your-secret-key-here-change-in-production"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

app = FastAPI(title="Authentication API")

fake_users_db = {
    "alice": {
        "username": "alice",
        "full_name": "Alice Johnson",
        "email": "alice@example.com",
        "hashed_password": pwd_context.hash("alice123"),
        "disabled": False,
        "role": "user"
    },
    "bob": {
        "username": "bob",
        "full_name": "Bob Smith",
        "email": "bob@example.com",
        "hashed_password": pwd_context.hash("bob123"),
        "disabled": False,
        "role": "admin"
    }
}

class Token(BaseModel):
    access_token: str
    token_type: str

class User(BaseModel):
    username: str
    email: Optional[str] = None
    full_name: Optional[str] = None
    disabled: Optional[bool] = None
    role: str

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_user(db, username: str):
    if username in db:
        user_dict = db[username]
        return User(**user_dict)
    return None

def authenticate_user(fake_db, username: str, password: str):
    user = get_user(fake_db, username)
    if not user:
        return False
    if not verify_password(password, fake_db[username]["hashed_password"]):
        return False
    return user

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

@app.post("/token", response_model=Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    user = authenticate_user(fake_users_db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/users/me", response_model=User)
async def read_users_me(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    user = get_user(fake_users_db, username)
    if user is None:
        raise credentials_exception
    return user

@app.get("/health")
async def health():
    return {"status": "healthy"}

@app.get("/debug")
async def debug(request: Request):
    return {"headers": dict(request.headers)}
```

### C.3.5 WebSocket Application

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

**File: `websocket-app/requirements.txt`**

```
fastapi==0.104.1
uvicorn[standard]==0.24.0
websockets==12.0
```

**File: `websocket-app/main.py`**

```python
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from typing import List
import json
import time

app = FastAPI(title="WebSocket Server")

class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

    async def broadcast(self, message: str):
        for connection in self.active_connections:
            await connection.send_text(message)

manager = ConnectionManager()

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        await manager.broadcast(f"User connected")
        while True:
            data = await websocket.receive_text()
            await manager.broadcast(f"Message: {data}")
    except WebSocketDisconnect:
        manager.disconnect(websocket)
        await manager.broadcast(f"User disconnected")

@app.get("/health")
async def health():
    return {"status": "healthy", "connections": len(manager.active_connections)}
```

### C.3.6 SSE Application

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

**File: `sse-app/requirements.txt`**

```
fastapi==0.104.1
uvicorn[standard]==0.24.0
```

**File: `sse-app/main.py`**

```python
from fastapi import FastAPI
from fastapi.responses import StreamingResponse
import asyncio
import json
import time

app = FastAPI(title="SSE Server")

async def generate_events():
    counter = 0
    while True:
        counter += 1
        event = {
            "counter": counter,
            "timestamp": time.time(),
            "message": f"Event #{counter}"
        }
        yield f"data: {json.dumps(event)}\n\n"
        await asyncio.sleep(1)

@app.get("/stream")
async def stream():
    return StreamingResponse(
        generate_events(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        }
    )

@app.get("/health")
async def health():
    return {"status": "healthy"}
```

### C.3.7 Webhook Application

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

**File: `webhook-app/requirements.txt`**

```
fastapi==0.104.1
uvicorn[standard]==0.24.0
```

**File: `webhook-app/main.py`**

```python
from fastapi import FastAPI, Request
import time
import uuid
import json

app = FastAPI(title="Webhook Receiver")

webhooks = []

@app.post("/inngest")
async def inngest_webhook(request: Request):
    payload = await request.json()
    webhook_id = str(uuid.uuid4())
    webhooks.append({
        "id": webhook_id,
        "source": "inngest",
        "payload": payload,
        "received_at": time.time()
    })
    return {"status": "received", "id": webhook_id}

@app.get("/webhooks")
async def get_webhooks():
    return {"webhooks": webhooks[-10:], "total": len(webhooks)}

@app.get("/health")
async def health():
    return {"status": "healthy"}
```

## C.4 Deployment Scripts

### C.4.1 deploy.sh

```bash
#!/bin/bash
set -e

echo "=== Nginx Gateway Deployment ==="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Step 1: Build
echo -e "${BLUE}Step 1: Building services${NC}"
docker compose build

# Step 2: Test configuration
echo -e "${BLUE}Step 2: Testing Nginx configuration${NC}"
docker compose run --rm nginx nginx -t

# Step 3: Start services
echo -e "${BLUE}Step 3: Starting services${NC}"
docker compose up -d

# Step 4: Wait for health
echo -e "${BLUE}Step 4: Waiting for services to become healthy${NC}"
sleep 10

# Step 5: Verify
echo -e "${BLUE}Step 5: Verifying deployment${NC}"
for i in {1..5}; do
    status=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost/health 2>/dev/null)
    if [ "$status" -eq 200 ]; then
        echo -e "${GREEN}✓ Gateway healthy${NC}"
        break
    fi
    if [ $i -eq 5 ]; then
        echo -e "${RED}✗ Gateway not healthy after 5 attempts${NC}"
        exit 1
    fi
    sleep 2
done

# Step 6: Show status
echo -e "${BLUE}Step 6: Deployment status${NC}"
docker compose ps

echo -e "${GREEN}=== Deployment Complete! ===${NC}"
echo "Gateway available at: https://localhost"
```

### C.4.2 monitor.sh

```bash
#!/bin/bash

echo "=== Nginx Gateway Monitoring ==="
echo ""

# Check services
echo "1. Services Status:"
docker compose ps

echo ""
echo "2. Request Rates (last minute):"
REQUESTS=$(tail -60 logs/access.log 2>/dev/null | wc -l)
echo "   $REQUESTS requests/min"

echo ""
echo "3. Active Connections:"
CONNS=$(docker exec nginx-proxy netstat -an 2>/dev/null | grep ':443' | grep ESTABLISHED | wc -l)
echo "   $CONNS active connections"

echo ""
echo "4. Cache Status:"
HITS=$(tail -100 logs/access.log 2>/dev/null | grep '"upstream_cache_status":"HIT"' | wc -l)
MISS=$(tail -100 logs/access.log 2>/dev/null | grep '"upstream_cache_status":"MISS"' | wc -l)
echo "   Hits: $HITS, Misses: $MISS"
```

### C.4.3 validate.sh

```bash
#!/bin/bash

echo "=== Nginx Gateway Validation ==="
echo ""

# Test HTTPS
echo -n "Testing HTTPS... "
if curl -k -s -o /dev/null -w "%{http_code}" https://localhost/ | grep -q 200; then
    echo "✓ OK"
else
    echo "✗ FAILED"
    exit 1
fi

# Test API
echo -n "Testing API... "
if curl -k -s https://localhost/api/ | grep -q "instance"; then
    echo "✓ OK"
else
    echo "✗ FAILED"
    exit 1
fi

# Test WebSocket
echo -n "Testing WebSocket... "
if curl -k -s -H "Connection: Upgrade" -H "Upgrade: websocket" \
    -H "Sec-WebSocket-Key: x3JJHMbDL1EzLkh9GBhXDw==" \
    -H "Sec-WebSocket-Version: 13" \
    https://localhost/ws/ 2>&1 | grep -q "101"; then
    echo "✓ OK"
else
    echo "✗ FAILED"
    exit 1
fi

# Test SSE
echo -n "Testing SSE... "
if curl -k -s -N https://localhost/sse/stream 2>&1 | head -2 | grep -q "data:"; then
    echo "✓ OK"
else
    echo "✗ FAILED"
    exit 1
fi

echo "All tests passed! ✓"
```

## C.5 SSL Certificate Generation

**File: `generate-ssl.sh`**

```bash
#!/bin/bash
# Generate self-signed SSL certificates for development

mkdir -p ssl

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ssl/localhost.key \
    -out ssl/localhost.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

echo "SSL certificates generated in ./ssl/"
```

## C.6 Quick Start

```bash
# Clone or create the environment
cd nginx-series/part-10

# Generate SSL certificates
./generate-ssl.sh

# Deploy everything
chmod +x deploy.sh monitor.sh validate.sh
./deploy.sh

# Validate the setup
./validate.sh

# Monitor the system
./monitor.sh

# Stop everything
docker compose down

# Clean everything (remove volumes)
docker compose down -v
```

---

This Docker Compose environment provides a complete, production-ready testbed for all the patterns and configurations in this series. It's designed to be self-contained, reproducible, and easy to modify for your own needs.
