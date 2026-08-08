# Part 2: Path-Based Routing for Polyglot Stacks

## The Target

We're going to transform our single-service proxy into a multi-service gateway. By the end of this part, you'll have:

- Three different applications running (Next.js, FastAPI, and Flask)
- Nginx routing to each service based on the URL path
- A complete understanding of `location` matching and precedence
- Mastery of the trailing-slash behavior in `proxy_pass`
- A load-balanced upstream group for one of your services

## The Concept: One Domain, Many Services

Think of your application like a large department store. Each department has its own specialty:
- **Ground floor** (`/`): The main showroom (Next.js frontend)
- **Electronics section** (`/api/`): Technical products (FastAPI backend)
- **Customer service** (`/admin/`): Administration (Django admin)

Customers enter through a single main entrance (your domain) and can go to any department without leaving the building. Each department operates independently but is accessible through the same front door.

This is exactly what path-based routing gives us:
```text
https://yourapp.com/          → Next.js (port 3000)
https://yourapp.com/api/      → FastAPI (port 8000)
https://yourapp.com/admin/    → Django/Flask (port 5000)
```

## The Pain Point: Multiple Services, Multiple Ports

Let's experience the problem firsthand. Without Nginx, you'd need to access each service on a different port:

```bash
# Without Nginx:
http://localhost:3000    # Next.js
http://localhost:8000    # FastAPI
http://localhost:5000    # Flask/Django
```

This creates several problems:
- Users need to remember port numbers
- Each service needs its own TLS certificate
- CORS configuration becomes complex
- You can't easily move services between servers
- Shared authentication is difficult

### Step 1: Set Up Our Multi-Service Architecture

We'll create three services and attempt to route them through Nginx.

First, let's create our directory structure:

```bash
mkdir -p nginx-series/part-02
cd nginx-series/part-02

mkdir -p nextjs-app fastapi-app flask-app
```

#### Next.js Application (Frontend)

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

**File: `nextjs-app/pages/index.js`**
```javascript
// Main landing page - served at /
export default function Home() {
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
        🏠 Next.js Frontend
      </h1>
      <p style={{ fontSize: '1.5rem', opacity: 0.9 }}>
        This is the main application
      </p>
      <p style={{ fontSize: '1rem', opacity: 0.7, marginTop: '2rem' }}>
        Try accessing <code style={{ background: 'rgba(255,255,255,0.2)', padding: '0.2rem 0.5rem', borderRadius: '4px' }}>/api/</code> or <code style={{ background: 'rgba(255,255,255,0.2)', padding: '0.2rem 0.5rem', borderRadius: '4px' }}>/admin/</code>
      </p>
    </div>
  );
}
```

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

**File: `nextjs-app/next.config.js`**
```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  // Next.js needs to know it's behind a proxy
  // So it generates correct URLs
  trailingSlash: true,
}

module.exports = nextConfig
```

#### FastAPI Application (API Service)

**File: `fastapi-app/requirements.txt`**
```
fastapi==0.104.1
uvicorn[standard]==0.24.0
```

**File: `fastapi-app/main.py`**
```python
# FastAPI application - serves the API endpoints

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import time
import uuid

# Create the FastAPI application
app = FastAPI(title="API Service", version="1.0.0")

# Add CORS middleware to handle cross-origin requests
# This allows the Next.js frontend to call this API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, restrict this to your domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Root endpoint for the API
@app.get("/")
async def root():
    """
    Root endpoint - shows API is running
    This is at /api/ (when proxied)
    """
    return {
        "service": "FastAPI",
        "status": "running",
        "version": "1.0.0",
        "endpoints": [
            "/api/",
            "/api/users",
            "/api/products",
            "/api/health"
        ]
    }

# Users endpoint
@app.get("/users")
async def get_users():
    """
    Get a list of users
    This is at /api/users (when proxied)
    """
    return {
        "users": [
            {"id": 1, "name": "Alice", "email": "alice@example.com"},
            {"id": 2, "name": "Bob", "email": "bob@example.com"},
            {"id": 3, "name": "Charlie", "email": "charlie@example.com"}
        ]
    }

# Products endpoint
@app.get("/products")
async def get_products():
    """
    Get a list of products
    This is at /api/products (when proxied)
    """
    return {
        "products": [
            {"id": 1, "name": "Laptop", "price": 999.99},
            {"id": 2, "name": "Mouse", "price": 29.99},
            {"id": 3, "name": "Keyboard", "price": 79.99}
        ]
    }

# Health check endpoint
@app.get("/health")
async def health_check():
    """
    Health check endpoint for monitoring
    This is at /api/health (when proxied)
    """
    return {
        "status": "healthy",
        "timestamp": time.time(),
        "service": "FastAPI"
    }

# Endpoint that returns the request info (for debugging headers)
@app.get("/debug")
async def debug_info(request):
    """
    Debug endpoint that echoes request information
    Useful for understanding what headers Nginx is forwarding
    """
    return {
        "headers": dict(request.headers),
        "client_host": request.client.host if request.client else None,
        "url": str(request.url),
        "method": request.method
    }
```

**File: `fastapi-app/Dockerfile`**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY main.py .

# Expose the FastAPI port
EXPOSE 8000

# Run with uvicorn in production mode
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### Flask Application (Admin Service)

**File: `flask-app/requirements.txt`**
```
Flask==2.3.3
Flask-CORS==4.0.0
```

**File: `flask-app/app.py`**
```python
# Flask application - serves the admin interface

from flask import Flask, jsonify, request
from flask_cors import CORS
import time

# Create the Flask application
app = Flask(__name__)

# Enable CORS for all routes
CORS(app)

# Admin root endpoint
@app.route('/')
def admin_root():
    """
    Admin root endpoint - shows admin dashboard
    This is at /admin/ (when proxied)
    """
    return jsonify({
        "service": "Flask Admin",
        "status": "online",
        "version": "2.3.3",
        "dashboard": {
            "users": 156,
            "orders": 432,
            "revenue": 54231.50
        },
        "endpoints": [
            "/admin/",
            "/admin/stats",
            "/admin/logs",
            "/admin/settings"
        ]
    })

# Statistics endpoint
@app.route('/stats')
def get_stats():
    """
    Get admin statistics
    This is at /admin/stats (when proxied)
    """
    return jsonify({
        "stats": {
            "total_users": 156,
            "active_users": 89,
            "total_orders": 432,
            "pending_orders": 12,
            "revenue": 54231.50,
            "last_updated": time.time()
        }
    })

# Logs endpoint
@app.route('/logs')
def get_logs():
    """
    Get recent admin logs
    This is at /admin/logs (when proxied)
    """
    return jsonify({
        "logs": [
            {"timestamp": time.time() - 3600, "level": "INFO", "message": "User alice logged in"},
            {"timestamp": time.time() - 1800, "level": "WARNING", "message": "Failed login attempt from 192.168.1.100"},
            {"timestamp": time.time() - 600, "level": "INFO", "message": "Order #4321 completed"},
            {"timestamp": time.time() - 300, "level": "ERROR", "message": "Payment processing timeout for order #4322"},
        ]
    })

# Settings endpoint
@app.route('/settings')
def get_settings():
    """
    Get admin settings
    This is at /admin/settings (when proxied)
    """
    return jsonify({
        "settings": {
            "site_name": "My Admin Panel",
            "theme": "dark",
            "notifications": True,
            "maintenance_mode": False,
            "timezone": "UTC",
            "features": {
                "analytics": True,
                "reports": True,
                "export": False
            }
        }
    })

# Debug endpoint that shows request info
@app.route('/debug')
def debug_info():
    """
    Debug endpoint showing request information
    """
    return jsonify({
        "headers": dict(request.headers),
        "remote_addr": request.remote_addr,
        "url": request.url,
        "method": request.method,
        "args": request.args.to_dict()
    })
```

**File: `flask-app/Dockerfile`**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

# Run with Flask's built-in server (for development only)
# In production, use gunicorn instead
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0", "--port=5000"]
```

### Step 2: The Broken Docker Compose Setup

Now let's create our `docker-compose.yml` with **intentionally problematic** Nginx configuration:

**File: `docker-compose.yml`**
```yaml
version: '3.8'

services:
  # Next.js Frontend Service
  nextjs:
    build:
      context: ./nextjs-app
      dockerfile: Dockerfile
    container_name: nextjs-app
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:3000"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network

  # FastAPI Service
  fastapi:
    build:
      context: ./fastapi-app
      dockerfile: Dockerfile
    container_name: fastapi-api
    ports:
      - "8000:8000"
    environment:
      - PYTHONUNBUFFERED=1
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network

  # Flask Admin Service
  flask:
    build:
      context: ./flask-app
      dockerfile: Dockerfile
    container_name: flask-admin
    ports:
      - "5000:5000"
    environment:
      - FLASK_APP=app.py
      - FLASK_ENV=production
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    networks:
      - app-network

  # Nginx Proxy - THIS CONFIG IS INTENTIONALLY BROKEN
  nginx:
    image: nginx:1.27-alpine
    container_name: nginx-proxy
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./logs:/var/log/nginx
    depends_on:
      nextjs:
        condition: service_healthy
      fastapi:
        condition: service_healthy
      flask:
        condition: service_healthy
    networks:
      - app-network

# Shared network for all services to communicate
networks:
  app-network:
    driver: bridge
```

**File: `nginx.conf` (INTENTIONALLY BROKEN)**
```nginx
# This configuration has multiple problems:
# 1. Wrong proxy_pass for /api/ (missing trailing slash)
# 2. Wrong proxy_pass for /admin/ (missing trailing slash)
# 3. Location priority issues

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

    server {
        listen 80;
        server_name localhost;

        # Root path -> Next.js
        location / {
            proxy_pass http://nextjs:3000;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # API path -> FastAPI
        # PROBLEM: Missing trailing slash will cause double-slash issues
        location /api/ {
            # This is WRONG - it will send /api/users to /api/users
            # But we want it to send /users
            proxy_pass http://fastapi:8000;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Admin path -> Flask
        # PROBLEM: Same issue - paths aren't being stripped correctly
        location /admin/ {
            # This is WRONG - sends /admin/stats to /admin/stats
            # But Flask expects /stats
            proxy_pass http://flask:5000;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

### Step 3: Run and Observe the Broken Behavior

Let's start our environment and see what happens:

```bash
# Start all services
docker compose up -d

# Wait for everything to start
sleep 10

# Check all services are running
docker compose ps
```

Now let's test each endpoint:

```bash
# 1. Root path - Should work!
curl -s http://localhost | grep "Next.js"
# ✅ Returns HTML with "Next.js Frontend"

# 2. API path - This should work, but notice the URL it returns
curl -s http://localhost/api/ | python -m json.tool
# Returns: {"service": "FastAPI", "status": "running", ...}
# But the endpoints listed include "/api/" prefix!

# 3. API users endpoint - THIS FAILS or returns wrong data
curl -s http://localhost/api/users | python -m json.tool
# PROBLEM: Returns 404 Not Found!
# FastAPI doesn't have a /api/users endpoint, it has /users

# 4. API products endpoint - Also fails
curl -s http://localhost/api/products | python -m json.tool
# PROBLEM: 404 Not Found - same issue

# 5. Admin root - Works but shows wrong paths
curl -s http://localhost/admin/ | python -m json.tool
# Returns: {"service": "Flask Admin", ...}
# But endpoints listed include "/admin/" prefix

# 6. Admin stats - FAILS
curl -s http://localhost/admin/stats | python -m json.tool
# PROBLEM: 404 Not Found - Flask doesn't have /admin/stats
```

### Step 4: Understanding the Failure

The problem is **path stripping**. Let's trace what's happening:

```text
Browser Request: GET /api/users
         │
         ▼
    Nginx Location: /api/
         │
         ▼
    proxy_pass: http://fastapi:8000
         │
         ▼
    FastAPI Receives: GET /api/users  ✗ WRONG! 
    FastAPI Expected: GET /users

Browser Request: GET /admin/stats
         │
         ▼
    Nginx Location: /admin/
         │
         ▼
    proxy_pass: http://flask:5000
         │
         ▼
    Flask Receives: GET /admin/stats  ✗ WRONG!
    Flask Expected: GET /stats
```

The `location /api/` matches requests starting with `/api/`. When `proxy_pass` doesn't have a trailing slash, it passes the **entire URI** to the upstream, including the `/api/` part.

**FastAPI is mounted at the root (`/`)**. It expects `/users`, not `/api/users`. We need Nginx to **strip the `/api/` prefix** before forwarding.

### Step 5: The Fix - Proper Path Stripping

The key insight: **The trailing slash in `proxy_pass` determines whether the location part is stripped.**

**Rule:**
- `proxy_pass http://upstream:port` → Sends the full URI (including location prefix)
- `proxy_pass http://upstream:port/` → Strips the location prefix

**File: `nginx.conf` (FIXED)**
```nginx
# This configuration correctly strips paths
# Each service gets the path it expects

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

    server {
        listen 80;
        server_name localhost;

        # Root path -> Next.js (no stripping needed)
        location / {
            proxy_pass http://nextjs:3000;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # API path -> FastAPI
        # FIXED: Trailing slash in proxy_pass strips /api/
        location /api/ {
            # The trailing slash is CRUCIAL here
            # It tells Nginx to strip /api/ before forwarding
            proxy_pass http://fastapi:8000/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Admin path -> Flask
        # FIXED: Trailing slash strips /admin/
        location /admin/ {
            proxy_pass http://flask:5000/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

### Step 6: Apply the Fix

```bash
# Test the configuration
docker exec nginx-proxy nginx -t

# Should show: syntax is ok

# Reload Nginx
docker exec nginx-proxy nginx -s reload
```

Now test again:

```bash
# 1. API root - still works
curl -s http://localhost/api/ | python -m json.tool
# Shows: {"service": "FastAPI", ...}

# 2. API users - NOW WORKS!
curl -s http://localhost/api/users | python -m json.tool
# Returns: {"users": [...]}

# 3. API products - NOW WORKS!
curl -s http://localhost/api/products | python -m json.tool
# Returns: {"products": [...]}

# 4. Admin root - works
curl -s http://localhost/admin/ | python -m json.tool
# Returns: {"service": "Flask Admin", ...}

# 5. Admin stats - NOW WORKS!
curl -s http://localhost/admin/stats | python -m json.tool
# Returns: {"stats": {...}}

# 6. Admin logs - NOW WORKS!
curl -s http://localhost/admin/logs | python -m json.tool
# Returns: {"logs": [...]}
```

### Step 7: The Trailing Slash Experiment

Now let's do a controlled experiment to understand trailing slash behavior completely:

**Experiment 1: Without Trailing Slash**

```nginx
location /api/ {
    proxy_pass http://fastapi:8000;  # No trailing slash
}
```

| Client Request | Nginx Sends to FastAPI |
|---------------|----------------------|
| `/api/` | `/api/` |
| `/api/users` | `/api/users` |
| `/api/products` | `/api/products` |

**Experiment 2: With Trailing Slash**

```nginx
location /api/ {
    proxy_pass http://fastapi:8000/;  # With trailing slash
}
```

| Client Request | Nginx Sends to FastAPI |
|---------------|----------------------|
| `/api/` | `/` |
| `/api/users` | `/users` |
| `/api/products` | `/products` |

**Experiment 3: With Path in proxy_pass (No trailing slash)**

```nginx
location /api/ {
    proxy_pass http://fastapi:8000/v1;  # No trailing slash
}
```

| Client Request | Nginx Sends to FastAPI |
|---------------|----------------------|
| `/api/` | `/v1/api/` |
| `/api/users` | `/v1/api/users` |

**Experiment 4: With Path in proxy_pass (With trailing slash)**

```nginx
location /api/ {
    proxy_pass http://fastapi:8000/v1/;  # With trailing slash
}
```

| Client Request | Nginx Sends to FastAPI |
|---------------|----------------------|
| `/api/` | `/v1/` |
| `/api/users` | `/v1/users` |

Let's test these differences in our environment. Create a test route in FastAPI:

**File: `fastapi-app/main.py` (add this endpoint)**
```python
# Add this to the FastAPI app
@app.get("/test")
async def test_route():
    """
    Test endpoint to see what path was requested
    """
    return {
        "message": "FastAPI received this request",
        "path": "/test",  # This is the actual path FastAPI sees
        "full_url": str(request.url)
    }
```

Now rebuild and test:

```bash
# Rebuild FastAPI to include the test endpoint
docker compose build fastapi
docker compose up -d fastapi

# Wait for it to start
sleep 5

# Test with different configurations (if you change nginx.conf)
# 1. Without trailing slash:
# /api/test → Nginx sends /api/test → FastAPI 404
curl -s http://localhost/api/test
# Returns: 404 Not Found

# 2. With trailing slash:
# /api/test → Nginx sends /test → FastAPI 200
curl -s http://localhost/api/test
# Returns: {"message": "FastAPI received this request", ...}
```

### Step 8: Advanced - Upstream Groups for Load Balancing

Now let's introduce upstream groups. Instead of pointing `proxy_pass` directly to a service, we can define an `upstream` block with multiple servers.

**File: `nginx.conf` (with upstream group)**
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

    # Upstream group for API services
    # This allows load balancing across multiple instances
    upstream api_backend {
        # Each server in the group
        # We only have one instance now, but we can add more
        server fastapi:8000;

        # Example with multiple instances:
        # server fastapi_1:8000 weight=3;
        # server fastapi_2:8000 weight=1;
        # server fastapi_3:8000 backup;

        # Keepalive connections for better performance
        keepalive 32;
    }

    upstream admin_backend {
        server flask:5000;

        # You can also add backup servers
        # server flask_backup:5000 backup;
    }

    upstream frontend_backend {
        server nextjs:3000;
    }

    server {
        listen 80;
        server_name localhost;

        # Root -> Next.js using upstream group
        location / {
            proxy_pass http://frontend_backend;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # Enable keepalive to upstream
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # API -> FastAPI using upstream group
        location /api/ {
            proxy_pass http://api_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # Admin -> Flask using upstream group
        location /admin/ {
            proxy_pass http://admin_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
    }
}
```

Test the upstream configuration:

```bash
# Test and reload
docker exec nginx-proxy nginx -t
docker exec nginx-proxy nginx -s reload

# All endpoints should still work
curl -s http://localhost/api/users | python -m json.tool
curl -s http://localhost/admin/stats | python -m json.tool
```

### Step 9: Location Precedence and Matching Rules

Nginx evaluates `location` blocks in a specific order. Understanding this is crucial when you have overlapping paths.

**Location Types (in priority order from highest to lowest):**

1. **Exact match** (`location = /path`)
2. **Preferential prefix** (`location ^~ /path`)
3. **Regex case-sensitive** (`location ~ /path`)
4. **Regex case-insensitive** (`location ~* /path`)
5. **Prefix match** (`location /path`)

Let's see this in action:

**File: `nginx.conf` (location precedence demo)**
```nginx
server {
    listen 80;
    server_name localhost;

    # 1. Exact match - highest priority
    # Matches ONLY /exact
    location = /exact {
        return 200 "This is an exact match\n";
    }

    # 2. Preferential prefix - highest priority before regex
    # Matches any path starting with /preferred
    # Stops regex evaluation
    location ^~ /preferred {
        return 200 "This is a preferential prefix match\n";
    }

    # 3. Regex match - case sensitive
    # Matches any path containing /pattern/ with case sensitivity
    location ~ /pattern/ {
        return 200 "This is a case-sensitive regex match\n";
    }

    # 4. Regex match - case insensitive
    # Matches any path containing /pattern/ ignoring case
    location ~* /pattern/ {
        return 200 "This is a case-insensitive regex match\n";
    }

    # 5. Prefix match - lowest priority
    # Matches any path starting with /docs
    location /docs {
        return 200 "This is a prefix match\n";
    }

    # 6. Catch-all - lowest priority
    location / {
        proxy_pass http://frontend_backend;
        # ... headers ...
    }
}
```

**Testing Location Precedence:**

```bash
# Test each pattern:
curl -v http://localhost/exact
# Should hit exact match

curl -v http://localhost/preferred/test
# Should hit preferential prefix

curl -v http://localhost/test/pattern/test
# Should hit regex match

curl -v http://localhost/docs
# Should hit prefix match (unless /docs/test matches regex)

curl -v http://localhost/anything
# Should hit catch-all
```

### Step 10: Advanced Location Matching

Let's create a configuration with sophisticated location matching:

**File: `nginx.conf` (advanced routing)**
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

    upstream api_backend {
        server fastapi:8000;
        keepalive 32;
    }

    upstream admin_backend {
        server flask:5000;
    }

    upstream frontend_backend {
        server nextjs:3000;
    }

    server {
        listen 80;
        server_name localhost;

        # Exact match for health check
        # This bypasses all processing and returns quickly
        location = /health {
            access_log off;
            return 200 "healthy\n";
        }

        # Match all static files - serve directly from Nginx
        # This is faster than going through the application
        location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg)$ {
            # Strip the /static/ prefix when serving
            # In production, these would be served from a CDN
            alias /usr/share/nginx/html/static/;
            expires 30d;
            add_header Cache-Control "public, immutable";
        }

        # Preferential prefix for API - stops regex matching
        # This ensures /api/ is always handled by the API service
        location ^~ /api/ {
            proxy_pass http://api_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # Preferential prefix for admin
        location ^~ /admin/ {
            proxy_pass http://admin_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # Regex for API version 2 - newer API
        # Case insensitive match for /api/v2/
        location ~* /api/v2/ {
            # This would route to a different backend in production
            proxy_pass http://api_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # Add API version header for the application
            proxy_set_header X-API-Version "2.0";
        }

        # Catch-all for the frontend
        location / {
            proxy_pass http://frontend_backend;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

## Verification Checklist

Before moving on, verify you've mastered path-based routing:

### ✅ Check 1: Root Path Routes Correctly
```bash
curl -s http://localhost | grep "Next.js"
# Should show Next.js frontend content
```

### ✅ Check 2: API Path Routes with Path Stripping
```bash
curl -s http://localhost/api/users | python -m json.tool
# Should show user list from FastAPI
```

### ✅ Check 3: Admin Path Routes with Path Stripping
```bash
curl -s http://localhost/admin/stats | python -m json.tool
# Should show stats from Flask
```

### ✅ Check 4: Trailing Slash Behavior Understood
```bash
# Test both forms
curl -v http://localhost/api
curl -v http://localhost/api/
# Notice the difference in how Nginx handles these
```

### ✅ Check 5: Upstream Group Works
```bash
# Check the upstream is working
docker logs nginx-proxy | grep "upstream"
# Should show upstream connections
```

### ✅ Check 6: Location Precedence Works as Expected
```bash
# Test different paths
curl -v http://localhost/health
# Should get "healthy" response

curl -v http://localhost/api/users
# Should route to FastAPI
```

### ✅ Check 7: No Path Double-Dipping
```bash
# Debug endpoint shows the full URL received
curl -s http://localhost/api/debug | python -m json.tool
# Check the "url" field - should be /api/debug
# But FastAPI sees /debug

# Verify the request URL is correctly reconstructed
curl -s http://localhost/api/debug | python -m json.tool | grep url
```

## Common Pitfalls and Solutions

### Pitfall 1: Missing Trailing Slash in proxy_pass

**Symptom:** 404 errors or wrong routes

**Wrong:**
```nginx
location /api/ {
    proxy_pass http://fastapi:8000;  # NO trailing slash
}
```
**Effect:** `/api/users` → `/api/users` (404 if app doesn't have `/api/users`)

**Right:**
```nginx
location /api/ {
    proxy_pass http://fastapi:8000/;  # WITH trailing slash
}
```
**Effect:** `/api/users` → `/users` (200 if app has `/users`)

### Pitfall 2: Using prefix when you mean regex

**Wrong:**
```nginx
location /api {  # Matches /api, /api123, /apinotwhatyouexpect
    # ...
}
```

**Right:**
```nginx
location /api/ {  # Matches /api/ and children only
    # ...
}
```

### Pitfall 3: Overlapping locations causing confusion

**Problem:**
```nginx
location /api/ { ... }
location /api/v1/ { ... }  # Will never match because /api/ catches it first
```

**Solution:** Use `^~` for more specific matches, or reorder:
```nginx
location ^~ /api/v1/ { ... }  # Higher priority
location /api/ { ... }        # Falls back to this
```

### Pitfall 4: Forgetting to add headers for applications

**Symptom:** Application can't generate correct URLs

**Wrong:**
```nginx
location /api/ {
    proxy_pass http://fastapi:8000/;
    # No headers - app thinks it's at /
}
```

**Right:**
```nginx
location /api/ {
    proxy_pass http://fastapi:8000/;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    # App knows it's behind a proxy
}
```

## What You've Learned

By completing Part 2, you can now:

- ✅ Route multiple services through a single Nginx instance
- ✅ Understand and apply path-based routing with `location` blocks
- ✅ Strip path prefixes correctly using trailing slashes in `proxy_pass`
- ✅ Explain the difference between `proxy_pass` with and without trailing slash
- ✅ Use `upstream` blocks for service groups
- ✅ Understand location precedence (exact > preferential > regex > prefix)
- ✅ Handle static assets efficiently with `location` matching
- ✅ Test and debug path routing issues
- ✅ Apply advanced matching with regex and preferential prefixes

## Reference: Location Matching Deep Dive

### Location Syntax Reference

| Syntax | Type | Priority | Example |
|--------|------|----------|---------|
| `location = /path` | Exact match | 1 (highest) | `location = /` |
| `location ^~ /path` | Preferential prefix | 2 | `location ^~ /api/` |
| `location ~ pattern` | Regex (case-sensitive) | 3 | `location ~ \.php$` |
| `location ~* pattern` | Regex (case-insensitive) | 4 | `location ~* \.jpg$` |
| `location /path` | Prefix match | 5 (lowest) | `location /docs` |

### Matching Examples

| Request URI | `location = /api` | `location /api/` | `location ~* /api/` |
|------------|------------------|------------------|---------------------|
| `/api` | ✅ (exact) | ❌ | ❌ |
| `/api/` | ❌ | ✅ (prefix) | ❌ |
| `/api/v1` | ❌ | ✅ (prefix) | ✅ (regex) |
| `/API/v1` | ❌ | ❌ | ✅ (case-insensitive) |

### proxy_pass URI Behavior Table

| Client Request | `proxy_pass` | Upstream Request |
|---------------|--------------|------------------|
| `/api/users` | `http://fastapi:8000` | `/api/users` |
| `/api/users` | `http://fastapi:8000/` | `/users` |
| `/api/users` | `http://fastapi:8000/v1` | `/v1/api/users` |
| `/api/users` | `http://fastapi:8000/v1/` | `/v1/users` |
| `/api/users/123` | `http://fastapi:8000` | `/api/users/123` |
| `/api/users/123` | `http://fastapi:8000/` | `/users/123` |

### When to Use Each Location Type

**Exact Match (`=`)**
- Health checks (`/health`)
- Root path specifically (`/`)
- Redirect endpoints

**Preferential Prefix (`^~`)**
- API routes that must not be affected by regex
- Admin routes
- Any critical path that should take precedence

**Regex (`~` or `~*`)**
- File extensions (`\.(jpg|png|css)$`)
- Pattern-based routing
- Version detection (`/api/v[0-9]+/`)

**Prefix (`/path`)**
- General routing
- Catch-all patterns
- Static content directories

## Next Steps

**Part 3: Production SSL, Domains & Let's Encrypt** takes everything we've built and secures it. You'll learn:

- TLS termination in Nginx
- HTTP to HTTPS redirects
- Getting real SSL certificates with Let's Encrypt
- Certificate renewal automation
- Forwarding protocols and headers correctly

You've built a multi-service gateway. Now let's make it secure.
