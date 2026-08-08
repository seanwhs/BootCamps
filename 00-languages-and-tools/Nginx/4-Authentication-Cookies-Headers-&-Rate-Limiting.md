# Part 4: Authentication, Cookies, Headers & Rate Limiting

## The Target

We're going to transform our secure gateway into an intelligent security perimeter that understands authentication, handles cookies correctly, and protects against abuse. By the end of this part, you'll have:

- Correct cookie forwarding and session handling behind a proxy
- Authentication-aware proxying with proper header forwarding
- Client IP detection and trusted proxy chains
- Rate limiting with different zones for different endpoints
- Security headers for protecting your applications
- Protection against common attacks (brute force, DDoS, injection)

## The Concept: Authentication as a Security Perimeter

Think of your application like a secure office building. Different areas have different access levels:

- **Public lobby** (`/`): Anyone can enter
- **Employee areas** (`/api/`): Need valid badge (authentication)
- **Executive suite** (`/admin/`): Need special clearance (authorization)
- **Server room** (`/internal/`): Only specific people (strict access control)

Nginx acts as the security guard at the front desk. It checks badges (cookies/tokens), tracks who's entering (rate limiting), and makes sure the right people get to the right places (header forwarding).

## The Pain Point: Authentication Breaks Behind a Proxy

Let's see what happens when authentication systems don't understand they're behind a proxy.

### Step 1: Setup Authentication-Aware Applications

First, let's create applications that understand authentication.

Create the directory structure:

```bash
mkdir -p nginx-series/part-04
cd nginx-series/part-04

# Copy our existing apps
cp -r ../part-03/nextjs-app .
cp -r ../part-03/fastapi-app .
cp -r ../part-03/flask-app .
cp -r ../part-03/ssl .

# Create a new authenticated app
mkdir -p auth-api
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
# Authentication API with JWT tokens
# Demonstrates how proxy headers affect authentication

from fastapi import FastAPI, HTTPException, Depends, status, Request
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from typing import Optional, Dict
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
import secrets

# Configuration
SECRET_KEY = "your-secret-key-here-change-in-production"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# Create FastAPI app
app = FastAPI(title="Authentication API", version="1.0.0")

# Fake database
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

# Pydantic models
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

class User(BaseModel):
    username: str
    email: Optional[str] = None
    full_name: Optional[str] = None
    disabled: Optional[bool] = None
    role: str

class UserInDB(User):
    hashed_password: str

# Helper functions
def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_user(db, username: str):
    if username in db:
        user_dict = db[username]
        return UserInDB(**user_dict)
    return None

def authenticate_user(fake_db, username: str, password: str):
    user = get_user(fake_db, username)
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
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

async def get_current_user(token: str = Depends(oauth2_scheme)):
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
        token_data = TokenData(username=username)
    except JWTError:
        raise credentials_exception
    user = get_user(fake_users_db, username=token_data.username)
    if user is None:
        raise credentials_exception
    return user

async def get_current_active_user(current_user: User = Depends(get_current_user)):
    if current_user.disabled:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

# API Endpoints
@app.post("/token", response_model=Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    """
    Login endpoint - returns JWT token
    This is at /auth/token when proxied
    """
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
async def read_users_me(current_user: User = Depends(get_current_active_user)):
    """
    Get current user info - requires authentication
    This is at /auth/users/me when proxied
    """
    return current_user

@app.get("/users/me/items")
async def read_own_items(current_user: User = Depends(get_current_active_user)):
    """
    Get user's items - demonstrates authenticated endpoint
    """
    return [{"item_id": "Foo", "owner": current_user.username}]

@app.get("/admin")
async def admin_only(current_user: User = Depends(get_current_active_user)):
    """
    Admin-only endpoint
    """
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not enough permissions")
    return {"message": "Welcome to the admin panel, " + current_user.full_name}

@app.get("/debug")
async def debug_info(request: Request):
    """
    Debug endpoint showing headers and authentication
    """
    auth_header = request.headers.get("authorization", "Not present")
    return {
        "headers": dict(request.headers),
        "auth_header": auth_header,
        "x_forwarded_for": request.headers.get("x-forwarded-for"),
        "x_real_ip": request.headers.get("x-real-ip"),
        "x_forwarded_proto": request.headers.get("x-forwarded-proto"),
        "client_host": request.client.host if request.client else None,
    }

@app.get("/")
async def root():
    """
    Root endpoint - shows available auth endpoints
    """
    return {
        "service": "Authentication API",
        "endpoints": {
            "token": "POST /auth/token",
            "user": "GET /auth/users/me",
            "admin": "GET /auth/admin",
            "debug": "GET /auth/debug"
        }
    }
```

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

### Step 2: The Broken Setup (Authentication Misconfiguration)

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
    environment:
      - NODE_ENV=production
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

  flask:
    build:
      context: ./flask-app
      dockerfile: Dockerfile
    container_name: flask-admin
    ports:
      - "5000:5000"
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
      - flask
      - auth-api
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

**File: `nginx.conf` (INTENTIONALLY BROKEN)**
```nginx
# This configuration has multiple problems:
# 1. Missing headers for authentication
# 2. Cookie handling issues
# 3. No rate limiting
# 4. Missing security headers

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

    upstream auth_backend {
        server auth-api:8001;
        keepalive 32;
    }

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
        listen 443 ssl http2;
        server_name localhost;

        ssl_certificate /etc/nginx/ssl/localhost.crt;
        ssl_certificate_key /etc/nginx/ssl/localhost.key;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
        ssl_prefer_server_ciphers off;

        # Root - frontend
        location / {
            proxy_pass http://frontend_backend;
            
            # PROBLEM: Missing X-Forwarded-Proto for HTTPS detection
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            # MISSING: proxy_set_header X-Forwarded-Proto $scheme;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # API - FastAPI
        location /api/ {
            proxy_pass http://api_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            # MISSING: Authentication headers
            # MISSING: X-Forwarded-Proto

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # Auth - Authentication API
        location /auth/ {
            proxy_pass http://auth_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            # PROBLEM: Missing cookie forwarding
            # PROBLEM: Missing CORS headers for cross-origin requests

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # Admin - Flask
        location /admin/ {
            proxy_pass http://admin_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            # MISSING: Authentication headers

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

### Step 3: Run and Observe Authentication Failures

```bash
# Start the services
docker compose up -d

# Wait for everything to start
sleep 10

# Test 1: Get a token from auth API
curl -k -X POST https://localhost/auth/token \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=alice&password=alice123"

# Should return a token

# Test 2: Access protected endpoint with token
TOKEN="your-token-from-above"
curl -k -X GET https://localhost/auth/users/me \
    -H "Authorization: Bearer $TOKEN"

# PROBLEM: This might fail due to missing headers

# Test 3: Check what the app sees
curl -k -X GET https://localhost/auth/debug \
    -H "Authorization: Bearer $TOKEN"
# Check the output - missing forwarded headers

# Test 4: Admin access should work but might fail
curl -k -X GET https://localhost/auth/admin \
    -H "Authorization: Bearer $TOKEN"

# Test 5: Check cookies - not being forwarded
curl -k -I https://localhost/auth/users/me \
    -H "Authorization: Bearer $TOKEN"
# Cookies might not be set correctly

# Test 6: Test rate limiting - none applied!
for i in {1..100}; do
    curl -k -s https://localhost/api/health > /dev/null
done
# No rate limiting - server could be overwhelmed
```

### Step 4: Understanding the Failures

**Problem 1: Missing X-Forwarded-Proto**
- Applications don't know if the request came over HTTPS
- Login redirects use HTTP instead of HTTPS
- Secure cookies aren't set

**Problem 2: Missing Authentication Headers**
- The auth token isn't being properly passed to services
- Some headers might be stripped

**Problem 3: Cookie Issues**
- Cookies set by the backend aren't being forwarded
- Paths and domains need to be configured

**Problem 4: No Rate Limiting**
- No protection against brute force attacks
- APIs can be overwhelmed

### Step 5: The Fix - Complete Authentication Configuration

**File: `nginx.conf` (FIXED)**
```nginx
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Log format that includes useful authentication info
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for" '
                    '"$http_authorization"';

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log;

    sendfile on;
    keepalive_timeout 65;

    # Rate Limiting Zones
    # Store rate limiting state in shared memory (10MB = ~160,000 IPs)
    limit_req_zone $binary_remote_addr zone=auth_limit:10m rate=5r/m;
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=60r/m;
    limit_req_zone $binary_remote_addr zone=admin_limit:10m rate=30r/m;

    # Upstream groups
    upstream auth_backend {
        server auth-api:8001;
        keepalive 32;
    }

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
        listen 443 ssl http2;
        server_name localhost;

        ssl_certificate /etc/nginx/ssl/localhost.crt;
        ssl_certificate_key /etc/nginx/ssl/localhost.key;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305';
        ssl_prefer_server_ciphers off;

        # Security Headers
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        add_header X-XSS-Protection "1; mode=block" always;
        
        # CORS Headers - allow cross-origin requests
        add_header Access-Control-Allow-Origin "*" always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Authorization, Content-Type, Accept" always;

        # Root path - frontend
        location / {
            proxy_pass http://frontend_backend;
            
            # Forward all necessary headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;  # FIXED
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Port $server_port;

            # Forward authorization header if present
            proxy_set_header Authorization $http_authorization;

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # API path - FastAPI
        location /api/ {
            # Apply API rate limiting
            limit_req zone=api_limit burst=10 nodelay;

            proxy_pass http://api_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;  # FIXED
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Port $server_port;
            
            # Forward authentication headers
            proxy_set_header Authorization $http_authorization;
            proxy_set_header Cookie $http_cookie;

            # CORS preflight handling
            if ($request_method = 'OPTIONS') {
                add_header Access-Control-Allow-Origin "*";
                add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
                add_header Access-Control-Allow-Headers "Authorization, Content-Type, Accept";
                add_header Content-Length 0;
                add_header Content-Type text/plain;
                return 204;
            }

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # Auth path - Authentication API
        location /auth/ {
            # STRICT rate limiting for auth endpoints
            limit_req zone=auth_limit burst=2 nodelay;

            proxy_pass http://auth_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;  # FIXED
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Port $server_port;
            
            # CRITICAL: Forward all authentication headers
            proxy_set_header Authorization $http_authorization;
            proxy_set_header Cookie $http_cookie;
            
            # Important for cookies
            proxy_cookie_path / "/; Secure; HttpOnly; SameSite=Lax";

            # CORS preflight handling
            if ($request_method = 'OPTIONS') {
                add_header Access-Control-Allow-Origin "*";
                add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
                add_header Access-Control-Allow-Headers "Authorization, Content-Type, Accept";
                add_header Content-Length 0;
                add_header Content-Type text/plain;
                return 204;
            }

            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }

        # Admin path - Flask
        location /admin/ {
            limit_req zone=admin_limit burst=5 nodelay;

            proxy_pass http://admin_backend/;
            
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;  # FIXED
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Port $server_port;
            
            # Forward authentication
            proxy_set_header Authorization $http_authorization;
            proxy_set_header Cookie $http_cookie;

            # Admin-specific security
            add_header X-Robots-Tag "noindex, nofollow" always;

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

### Step 6: Advanced - Cookie Handling Behind Proxy

Cookie handling is critical for authentication. Let's create a configuration that properly handles cookies:

**File: `nginx-cookie-handling.conf`**
```nginx
# Cookie handling snippet
# Include this in your auth location block

location /auth/ {
    proxy_pass http://auth_backend/;
    
    # Cookie path rewriting
    # If your app sets a cookie with path /, but it's behind /auth/
    # You might need to rewrite the path
    proxy_cookie_path / "/auth; Secure; HttpOnly; SameSite=Lax";
    proxy_cookie_path /auth "/auth; Secure; HttpOnly; SameSite=Lax";
    
    # Domain rewriting (if your domain changes)
    # proxy_cookie_domain localhost yourdomain.com;
    
    # Forward all cookie-related headers
    proxy_set_header Cookie $http_cookie;
    proxy_set_header Set-Cookie $upstream_http_set_cookie;
    
    # Additional headers for cookie-based auth
    proxy_set_header X-Session-ID $cookie_sessionid;
}
```

### Step 7: Testing the Authentication Flow

Let's test our complete authentication flow:

```bash
# Step 1: Test the configuration
docker exec nginx-proxy nginx -t
docker exec nginx-proxy nginx -s reload

# Step 2: Get a token
TOKEN=$(curl -k -s -X POST https://localhost/auth/token \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=alice&password=alice123" \
    | python -m json.tool | grep access_token | cut -d'"' -f4)

echo "Token: $TOKEN"

# Step 3: Access protected endpoint
curl -k -X GET https://localhost/auth/users/me \
    -H "Authorization: Bearer $TOKEN" \
    | python -m json.tool

# Should show user info

# Step 4: Access admin endpoint (alice is not admin)
curl -k -X GET https://localhost/auth/admin \
    -H "Authorization: Bearer $TOKEN" \
    | python -m json.tool

# Should return 403 Forbidden

# Step 5: Login as admin
ADMIN_TOKEN=$(curl -k -s -X POST https://localhost/auth/token \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=bob&password=bob123" \
    | python -m json.tool | grep access_token | cut -d'"' -f4)

# Access admin endpoint
curl -k -X GET https://localhost/auth/admin \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    | python -m json.tool

# Should show admin welcome message

# Step 6: Test rate limiting - should see 429 after too many requests
for i in {1..10}; do
    echo "Request $i:"
    curl -k -s -o /dev/null -w "%{http_code}\n" \
        -X POST https://localhost/auth/token \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "username=alice&password=alice123"
done
# Should see 429 Too Many Requests after 5-6 requests

# Step 7: Check debug endpoint to see forwarded headers
curl -k -X GET https://localhost/auth/debug \
    -H "Authorization: Bearer $TOKEN" \
    | python -m json.tool

# Verify that X-Forwarded-Proto is "https"
# Verify that authorization header is present
# Verify that real IP is being forwarded
```

### Step 8: Rate Limiting Configuration Deep Dive

Rate limiting is essential for protecting your services. Let's explore advanced rate limiting configurations:

**File: `nginx-rate-limiting.conf`**
```nginx
# Rate Limiting Configuration
# Place this in the http block

# Define rate limiting zones
# $binary_remote_addr uses the client IP (much more memory efficient than $remote_addr)
limit_req_zone $binary_remote_addr zone=auth_limit:10m rate=5r/m;
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=60r/m;
limit_req_zone $binary_remote_addr zone=admin_limit:10m rate=30r/m;
limit_req_zone $binary_remote_addr zone=static_limit:10m rate=300r/m;

# Connection limiting - limit concurrent connections per IP
# Use for login endpoints to prevent connection exhaustion
limit_conn_zone $binary_remote_addr zone=auth_conn:10m;

# Rate limit for specific paths
location /auth/login {
    # 5 requests per minute, burst of 2, no delay
    limit_req zone=auth_limit burst=2 nodelay;
    
    # Max 1 concurrent connection
    limit_conn auth_conn 1;
    
    proxy_pass http://auth_backend/login;
}

location /api/ {
    # 60 requests per minute, burst of 10
    limit_req zone=api_limit burst=10 nodelay;
    
    proxy_pass http://api_backend/;
}

location /api/public/ {
    # Stricter limit for public endpoints
    limit_req zone=api_limit burst=5;
    proxy_pass http://api_backend/public/;
}

location /api/internal/ {
    # No rate limit for internal endpoints
    # But restrict access by IP
    allow 10.0.0.0/8;
    allow 172.16.0.0/12;
    deny all;
    
    proxy_pass http://api_backend/internal/;
}

# Custom rate limiting responses
location @rate_limited {
    return 429 "Rate limit exceeded. Please try again later.\n";
}

# Apply rate limiting with custom error page
location /api/ {
    limit_req zone=api_limit burst=10 nodelay;
    error_page 429 = @rate_limited;
    
    proxy_pass http://api_backend/;
}
```

### Step 9: Client IP Detection and Trusted Proxies

One of the biggest security issues is trusting `X-Forwarded-For` from untrusted sources. Let's configure this properly:

**File: `nginx-client-ip.conf`**
```nginx
# Client IP Detection
# Place this in the location blocks

location /api/ {
    # Set real IP from X-Forwarded-For header
    # But only trust specific proxies (your load balancers)
    set_real_ip_from 10.0.0.0/8;      # Internal network
    set_real_ip_from 172.16.0.0/12;   # Docker networks
    set_real_ip_from 192.168.0.0/16;  # Local networks
    real_ip_header X-Forwarded-For;
    real_ip_recursive on;

    # Now $remote_addr is the real client IP
    # Use it for rate limiting
    limit_req zone=api_limit burst=10 nodelay;
    
    # Pass the real client IP to the application
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    
    proxy_pass http://api_backend/;
}

# Alternative: Don't trust any proxy (security over convenience)
location /admin/ {
    # Only use the direct IP
    proxy_set_header X-Real-IP $remote_addr;
    # Don't set X-Forwarded-For at all
    
    proxy_pass http://admin_backend/;
}
```

### Step 10: Security Headers Deep Dive

Let's add comprehensive security headers:

**File: `nginx-security-headers.conf`**
```nginx
# Security Headers Snippet
# Include this in your server block

# Strict Transport Security - enforce HTTPS for 1 year
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

# Prevent MIME type sniffing
add_header X-Content-Type-Options "nosniff" always;

# Prevent clickjacking
add_header X-Frame-Options "DENY" always;

# Enable XSS protection
add_header X-XSS-Protection "1; mode=block" always;

# Control referrer information
add_header Referrer-Policy "strict-origin-when-cross-origin" always;

# Permissions Policy - control browser features
add_header Permissions-Policy "geolocation=(), microphone=(), camera=(), payment=()" always;

# Content Security Policy - prevent XSS and injection
# Start with a permissive policy and tighten
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data:;" always;

# Cache static assets
location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf)$ {
    add_header Cache-Control "public, max-age=31536000, immutable";
    add_header X-Content-Type-Options "nosniff";
}

# Prevent caching of sensitive responses
location /api/ {
    add_header Cache-Control "no-store, no-cache, must-revalidate, proxy-revalidate";
    add_header Pragma "no-cache";
    add_header Expires "0";
}
```

## Verification Checklist

Before moving on, verify you've mastered authentication and rate limiting:

### ✅ Check 1: Authentication Works
```bash
# Get a token
TOKEN=$(curl -k -s -X POST https://localhost/auth/token \
    -d "username=alice&password=alice123" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    | python -m json.tool | grep access_token | cut -d'"' -f4)

# Access protected endpoint
curl -k -s -X GET https://localhost/auth/users/me \
    -H "Authorization: Bearer $TOKEN" \
    | python -m json.tool
# Should show user info
```

### ✅ Check 2: Admin Access Controls Work
```bash
# Bob (admin) can access admin
BOB_TOKEN=$(curl -k -s -X POST https://localhost/auth/token \
    -d "username=bob&password=bob123" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    | python -m json.tool | grep access_token | cut -d'"' -f4)

curl -k -s -X GET https://localhost/auth/admin \
    -H "Authorization: Bearer $BOB_TOKEN" \
    | python -m json.tool
# Should show admin welcome message
```

### ✅ Check 3: Rate Limiting Works
```bash
# Make 10 rapid login attempts
for i in {1..10}; do
    echo "Attempt $i: $(curl -k -s -o /dev/null -w "%{http_code}" \
        -X POST https://localhost/auth/token \
        -d "username=alice&password=alice123" \
        -H "Content-Type: application/x-www-form-urlencoded")"
done
# Should show 200, 200, 200, 200, 200, 429, 429, 429, 429, 429
```

### ✅ Check 4: Headers Forwarded Correctly
```bash
curl -k -s -X GET https://localhost/auth/debug \
    -H "Authorization: Bearer $TOKEN" \
    | python -m json.tool | grep -A10 "headers"
# Should show:
# "authorization": "Bearer ..."
# "x-forwarded-proto": "https"
# "x-forwarded-for": "..." 
# "x-real-ip": "..."
```

### ✅ Check 5: Security Headers Present
```bash
curl -k -I https://localhost/auth/token \
    | grep -E "Strict-Transport|X-Content|X-Frame|X-XSS|Referrer"
# Should show all security headers
```

### ✅ Check 6: Cookie Handling Works
```bash
# Check cookie flags
curl -k -I https://localhost/auth/token \
    | grep "Set-Cookie"
# Should show Secure, HttpOnly, SameSite flags
```

## Common Pitfalls and Solutions

### Pitfall 1: Authentication Headers Not Forwarded

**Symptom:** Protected endpoints return 401 Unauthorized

**Wrong:**
```nginx
location /api/ {
    proxy_pass http://api_backend/;
    # Missing Authorization header forwarding
}
```

**Right:**
```nginx
location /api/ {
    proxy_pass http://api_backend/;
    proxy_set_header Authorization $http_authorization;
}
```

### Pitfall 2: Cookies Not Handled Correctly

**Symptom:** Session cookies not persisting

**Wrong:**
```nginx
location /auth/ {
    proxy_pass http://auth_backend/;
    # No cookie handling
}
```

**Right:**
```nginx
location /auth/ {
    proxy_pass http://auth_backend/;
    proxy_set_header Cookie $http_cookie;
    proxy_set_header Set-Cookie $upstream_http_set_cookie;
    proxy_cookie_path / "/auth";
}
```

### Pitfall 3: Too Aggressive Rate Limiting

**Symptom:** Legitimate users get 429 errors

**Wrong:**
```nginx
limit_req zone=auth_limit rate=1r/m;
```

**Right:** Add burst and nodelay
```nginx
limit_req zone=auth_limit burst=2 nodelay;
```

### Pitfall 4: Trusting X-Forwarded-For from Untrusted Sources

**Symptom:** IP spoofing attacks

**Wrong:**
```nginx
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
# No trusted proxy configuration
```

**Right:**
```nginx
# Only trust specific proxies
set_real_ip_from 10.0.0.0/8;
real_ip_header X-Forwarded-For;
```

## What You've Learned

By completing Part 4, you can now:

- ✅ Forward authentication headers correctly
- ✅ Handle cookies behind a proxy
- ✅ Configure rate limiting for different endpoints
- ✅ Set up client IP detection with trusted proxies
- ✅ Add comprehensive security headers
- ✅ Protect against brute force attacks
- ✅ Handle CORS for cross-origin requests
- ✅ Configure different rate limits for different paths
- ✅ Test authentication flows
- ✅ Debug authentication issues

## Reference: Authentication Patterns

### Cookie-Based Authentication Flow
```text
Browser → Nginx → Application
   │          │          │
   │          ├─ Cookie  │
   │          │  forward │
   │          ←──────────┤
   │          │          │
   │   Set-Cookie        │
   ←─────────────────────┤
   │          │          │
   │  Cookie  │          │
   ──────────→│          │
   │          ├─ Cookie  │
   │          │  forward │
   │          ──────────→│
```

### JWT-Based Authentication Flow
```text
Browser → Nginx → Auth API
   │          │          │
   │          │  Login   │
   │          ──────────→│
   │          │          │
   │   Token  │          │
   ←─────────────────────┤
   │          │          │
   │  Bearer  │          │
   │  Token   │          │
   ──────────→│          │
   │          ├─ Bearer  │
   │          │  Token   │
   │          ──────────→│
```

### Rate Limiting Patterns

| Use Case | Rate | Burst | Zone |
|----------|------|-------|------|
| Login | 5r/m | 2 | `auth_limit` |
| API | 60r/m | 10 | `api_limit` |
| Admin | 30r/m | 5 | `admin_limit` |
| Public | 300r/m | 30 | `public_limit` |

## Next Steps

**Part 5: WebSockets, SSE & Inngest Webhooks** builds on everything you've learned. You'll handle:

- WebSocket connections with proper upgrades
- Server-Sent Events (SSE) streaming
- Webhook handling with Inngest
- Long-running connections and timeouts

Your gateway is secure and intelligent. Now let's make it real-time.
