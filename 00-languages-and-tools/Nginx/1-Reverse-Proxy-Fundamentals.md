# Part 1: Reverse Proxy Fundamentals

## The Target

We're going to build our first Nginx reverse proxy. By the end of this part, you'll have:

- A running Nginx container accepting traffic on port `80`
- A Next.js application running on port `3000` (inside Docker)
- Nginx configured to forward requests from `http://localhost` to the Next.js app
- Complete understanding of the request flow: Browser → Nginx → Next.js
- A working configuration you've tested and verified

## The Concept: What's a Reverse Proxy?

Imagine you're the receptionist at a large company. Visitors come to the front desk and say, "I need to speak to someone in accounting." You don't send them to accounting's direct phone number; you note their request, transfer them to the right person, and handle any issues with the transfer.

**A reverse proxy works exactly like that receptionist.** 

**Forward Proxy vs. Reverse Proxy:**

| Forward Proxy | Reverse Proxy |
|--------------|---------------|
| Clients inside a network use it to reach the internet | Internet clients use it to reach internal services |
| "I need to get out" | "You need to get in" |
| Hides the client's identity | Hides the server's identity |
| Example: Corporate network filtering | Example: Nginx in front of your app |

Your application server (Next.js) runs on port `3000`. You could tell users to access `http://yourapp.com:3000`, but that's ugly, insecure, and doesn't scale. Instead, Nginx listens on the standard HTTP port (`80`), accepts the request, and forwards it to your application.

## The Pain Point: The Port Problem

Let's experience the problem ourselves.

### Step 1: Start Our Application Without Nginx

We'll create a simple Next.js application. But here's the catch—it will fail to start because we haven't configured it properly yet.

Create this directory structure:

```bash
mkdir -p nginx-series/part-01
cd nginx-series/part-01
```

Now create our first broken application:

**File: `nextjs-app/package.json`**

```json
{
  "name": "nextjs-app",
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
// The simplest possible Next.js page
// This will be served at the root path (/)
export default function Home() {
  return (
    <div style={{ 
      display: 'flex', 
      flexDirection: 'column',
      alignItems: 'center', 
      justifyContent: 'center',
      height: '100vh',
      fontFamily: 'system-ui, sans-serif'
    }}>
      <h1>🚀 Next.js is Running!</h1>
      <p>Port: 3000 (inside the container)</p>
      <p>But can you reach me from outside?</p>
    </div>
  );
}
```

**File: `nextjs-app/Dockerfile`**

```dockerfile
# Use the official Node.js image with Alpine Linux for a small footprint
FROM node:20-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first (for better caching)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the Next.js application (creates the .next folder)
RUN npm run build

# Expose port 3000 (the default Next.js port)
EXPOSE 3000

# Command to start the application in production mode
CMD ["npm", "start"]
```

**File: `nextjs-app/next.config.js`**

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  // Next.js automatically runs on port 3000
  // We don't need to change anything here
}

module.exports = nextConfig
```

### Step 2: Create the Broken Docker Compose Setup

Now let's create a Docker Compose file that will try to run our Next.js app and Nginx—but Nginx will be misconfigured on purpose.

**File: `docker-compose.yml`**

```yaml
version: '3.8'

services:
  # The Next.js application - this one is correct
  nextjs:
    build:
      context: ./nextjs-app
      dockerfile: Dockerfile
    container_name: nextjs-app
    ports:
      # Map host port 3000 to container port 3000
      # This means we can access the app at localhost:3000
      - "3000:3000"
    environment:
      - NODE_ENV=production
    # Health check to verify the app is running
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

  # Nginx reverse proxy - THIS IS INTENTIONALLY BROKEN
  nginx:
    image: nginx:1.27-alpine
    container_name: nginx-proxy
    ports:
      # Map host port 80 to container port 80
      - "80:80"
    volumes:
      # Mount our custom nginx config (which has an error)
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      # Mount logs for debugging
      - ./logs:/var/log/nginx
    depends_on:
      nextjs:
        condition: service_healthy
    # No network config yet - we'll fix this later
```

**File: `nginx.conf` (THIS CONFIG IS DELIBERATELY BROKEN)**

```nginx
# The main nginx configuration file
# We're using the standard structure with events and http blocks

events {
    # The maximum number of simultaneous connections
    # Nginx can handle more connections than this, but this sets a baseline
    worker_connections 1024;
}

http {
    # The http block contains all web server configuration

    # Include mime types (for handling different file types)
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging configuration
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # Sendfile is performance optimization for static files
    sendfile on;
    keepalive_timeout 65;

    # This is our main server block - where the magic happens
    server {
        # Listen on port 80 (HTTP)
        listen 80;

        # Handle requests to localhost
        server_name localhost;

        # The location block matches the root path
        location / {
            # Attempt to proxy to the Next.js app
            # BUT THE PORT IS WRONG - THIS WILL FAIL
            # It should be 3000, not 3001
            proxy_pass http://127.0.0.1:3001;
        }
    }
}
```

### Step 3: Run the Broken Setup

Let's start our environment and see what happens:

```bash
# Start the containers
docker compose up -d

# Wait a moment for everything to start
sleep 5

# Check if the containers are running
docker compose ps
```

You should see both containers running. Now let's test the Next.js application directly:

```bash
# This should work - the app is running on port 3000
curl -v http://localhost:3000
```

You'll see output similar to:

```
*   Trying 127.0.0.1:3000...
* Connected to localhost (127.0.0.1) port 3000
> GET / HTTP/1.1
> Host: localhost:3000
> User-Agent: curl/8.4.0
> Accept: */*
> 
< HTTP/1.1 200 OK
< Content-Type: text/html; charset=utf-8
< ...
```

Great! The Next.js app works. Now try to reach it through Nginx:

```bash
# This should FAIL - Nginx is pointing to the wrong port
curl -v http://localhost
```

You'll see:

```
*   Trying 127.0.0.1:80...
* Connected to localhost (127.0.0.1) port 80
> GET / HTTP/1.1
> Host: localhost
> User-Agent: curl/8.4.0
> Accept: */*
> 
< HTTP/1.1 502 Bad Gateway
< Server: nginx/1.27.0
< Date: Sun, 08 Aug 2026 12:00:00 GMT
< Content-Type: text/html
< Content-Length: 497
< Connection: keep-alive
< ETag: "669f5d94-1f1"
< 
<!DOCTYPE html>
<html>
<head><title>502 Bad Gateway</title></head>
<body>
...
```

**502 Bad Gateway** - Nginx can't connect to the upstream server.

### Step 4: Debugging the Failure

Let's investigate what happened. We'll check the Nginx error log:

```bash
# View the error logs
docker logs nginx-proxy

# OR check the mounted log file
cat logs/error.log
```

You'll see something like:

```
2026/08/08 12:00:01 [error] 30#30: *1 connect() failed (111: Connection refused) while connecting to upstream, 
client: 172.18.0.1, server: localhost, request: "GET / HTTP/1.1", upstream: "http://127.0.0.1:3001/", 
host: "localhost"
```

**The error tells us exactly what's wrong:**

- `connect() failed (111: Connection refused)` - Nginx tried to connect but got refused
- `upstream: "http://127.0.0.1:3001/"` - It's trying to connect to port 3001
- `client: 172.18.0.1` - The request came from the Docker network

### Step 5: Understanding Docker Networking

This is a critical concept: **inside a Docker container, `127.0.0.1` refers to the container itself, not your host machine.**

Our architecture looks like this:

```text
Browser (your host)
   │
   │  http://localhost:80
   ▼
Nginx Container (172.18.0.2)
   │
   │  Tries to connect to 127.0.0.1:3001
   │  This is INSIDE the container - NOTHING runs on port 3001 there!
   ▼
   ✗ Connection Refused
```

The Next.js app is running in a *different* container. Nginx can't reach it via `127.0.0.1` because that's the container's own network interface.

**Solution:** Nginx needs to use the container name or service name as the hostname.

In Docker Compose, services can reach each other using their service names. So:

- `http://nextjs:3000` is the correct address for Nginx to reach the Next.js app
- Not `http://127.0.0.1:3001` (wrong port, wrong host)

### Step 6: The Fix

We need to change two things in the Nginx configuration:

1. The proxy host from `127.0.0.1` to `nextjs` (the service name)
2. The port from `3001` to `3000` (the actual port)

**File: `nginx.conf` (FIXED)**

```nginx
# The main nginx configuration file
# This version WORKS correctly

events {
    # The maximum number of simultaneous connections
    # This is a reasonable starting value
    worker_connections 1024;
}

http {
    # The http block contains all web server configuration

    # Include mime types (for handling different file types)
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging configuration
    # Access log tracks all requests
    access_log /var/log/nginx/access.log;
    # Error log tracks errors and warnings
    error_log /var/log/nginx/error.log;

    # Performance optimizations
    sendfile on;           # Efficient file transfer
    keepalive_timeout 65;  # Keep connections alive for reuse

    # This is our main server block
    server {
        # Listen on port 80 (standard HTTP port)
        listen 80;

        # Handle requests to localhost
        # In production, this would be your domain name
        server_name localhost;

        # The location block matches the root path (/)
        # This means all requests will be handled here
        location / {
            # FIXED: Use the correct Docker service name and port
            # 'nextjs' is the service name from docker-compose.yml
            proxy_pass http://nextjs:3000;

            # IMPORTANT: We're also adding essential headers
            # These tell the application the original request details
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

### Step 7: Apply the Fix

Now let's apply our fixed configuration:

```bash
# First, test the configuration syntax
docker exec nginx-proxy nginx -t

# You should see:
# nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
# nginx: configuration file /etc/nginx/nginx.conf test is successful

# If the test passes, reload Nginx to apply changes
docker exec nginx-proxy nginx -s reload

# Alternatively, you can restart the container
docker compose restart nginx
```

Wait a moment for Nginx to reload, then test:

```bash
# This should now WORK!
curl -v http://localhost
```

You'll see:

```
*   Trying 127.0.0.1:80...
* Connected to localhost (127.0.0.1) port 80
> GET / HTTP/1.1
> Host: localhost
> User-Agent: curl/8.4.0
> Accept: */*
> 
< HTTP/1.1 200 OK
< Server: nginx/1.27.0
< Date: Sun, 08 Aug 2026 12:05:00 GMT
< Content-Type: text/html; charset=utf-8
< Content-Length: 345
< Connection: keep-alive
< 
<!DOCTYPE html>
<html>
  ...
</html>
```

**Success!** The request went Browser → Nginx (port 80) → Next.js (port 3000, inside the container).

### Step 8: Verify the Request Flow

Let's verify each component is working correctly:

```bash
# 1. Check that Next.js is serving the page directly (bypassing Nginx)
curl -I http://localhost:3000
# Should show: HTTP/1.1 200 OK

# 2. Check that Nginx is forwarding correctly
curl -I http://localhost
# Should show: HTTP/1.1 200 OK (with Server: nginx header)

# 3. Check the Nginx access log to see the request
tail -n 5 logs/access.log
# Should show entries for the requests you just made

# 4. Check the Nginx error log (should be empty or show startup messages)
tail -n 5 logs/error.log
# Should not show any errors
```

### Step 9: Open Your Browser

Open your browser and navigate to `http://localhost`. You should see the Next.js application rendered in all its glory.

But wait—we can also access it at `http://localhost:3000`. Let's understand the difference:

- `http://localhost:3000` → Direct access to Next.js (bypassing Nginx)
- `http://localhost` → Through Nginx reverse proxy (port 80)

In production, you would:
1. Block direct access to port 3000 (firewall rules)
2. Only expose Nginx on ports 80 and 443
3. Users only see `https://yourapp.com`

### Step 10: The Anatomy of Our Configuration

Let's break down what each part of our Nginx configuration does:

**`events` Block:**
```nginx
events {
    worker_connections 1024;
}
```
- `worker_connections`: Maximum number of simultaneous connections each worker process can handle
- 1024 is a good starting value; adjust based on your traffic

**`http` Block:**
```nginx
http {
    # All web-specific configuration goes here
}
```
- The main container for HTTP-related settings
- Think of it as "everything that handles web requests"

**`server` Block:**
```nginx
server {
    listen 80;
    server_name localhost;
    # ...
}
```
- Defines a virtual server
- `listen`: What port/interface to accept requests on
- `server_name`: Which hostname this block handles
- You can have multiple server blocks for different domains

**`location` Block:**
```nginx
location / {
    proxy_pass http://nextjs:3000;
    # ...
}
```
- Matches a specific URL pattern
- `/` matches everything (the root)
- Different `location` blocks can handle different paths
- `proxy_pass`: The address to forward the request to

**`proxy_set_header` Directives:**
```nginx
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
```
- Modify request headers before forwarding
- `$host`: Original host from the client request
- `$remote_addr`: Client IP address
- `$proxy_add_x_forwarded_for`: Chain of IPs (client → proxy → ...)
- `$scheme`: Original protocol (http or https)
- These headers help your application know the "real" request details

## Deep Dive: The Request Lifecycle

When you visit `http://localhost`, this is what happens:

1. **DNS Resolution** (skipped for localhost)
   - Browser resolves `localhost` to `127.0.0.1`

2. **TCP Connection**
   - Browser opens a connection to `127.0.0.1:80`
   - Your Docker daemon forwards this to the Nginx container

3. **Nginx Accepts the Connection**
   - Nginx reads the HTTP request
   - Identifies the `Host` header (`localhost`)
   - Matches it to the `server_name` in our configuration

4. **Location Matching**
   - Nginx looks at the URI (`/`)
   - Finds the `location /` block
   - This matches all requests

5. **Proxy Processing**
   - Nginx prepares to forward the request
   - Replaces the host with `nextjs` (the service name)
   - Uses port `3000`
   - Adds the proxy headers

6. **Upstream Connection**
   - Nginx resolves `nextjs` to the container IP using Docker's internal DNS
   - Opens a connection to `http://nextjs:3000`
   - Forwards the modified request

7. **Application Response**
   - Next.js processes the request
   - Returns the HTML page
   - Nginx receives the response

8. **Response to Client**
   - Nginx adds its own headers (Server: nginx)
   - Sends the response back to your browser
   - Your browser renders the page

9. **Connection Management**
   - Nginx may keep the connection alive for reuse
   - `keepalive_timeout` controls how long to wait

## Verification Checklist

Before moving on, ensure you can complete all these checks:

### ✅ Check 1: Direct Application Access
```bash
curl -s http://localhost:3000 | grep "Next.js"
# Should show the HTML containing "Next.js is Running!"
```

### ✅ Check 2: Nginx Proxy Access
```bash
curl -s http://localhost | grep "Next.js"
# Should show the same HTML
```

### ✅ Check 3: Proxy Headers Pass Through
```bash
# Check if Nginx is setting the proper headers
# This requires looking at application logs, but we'll test a simple way:
docker logs nextjs-app | tail -n 10
# Should show requests coming in, ideally with the forwarded headers
```

### ✅ Check 4: No Error Logs
```bash
cat logs/error.log
# Should be empty or only contain startup info
```

### ✅ Check 5: Access Logs Show Requests
```bash
cat logs/access.log | grep -v "favicon"
# Should show entries for your curl/browser requests
```

### ✅ Check 6: Docker Network Connectivity
```bash
# Verify the containers can communicate
docker exec nginx-proxy ping nextjs
# Should show ping responses from the nextjs container
```

### ✅ Check 7: Configuration Test
```bash
docker exec nginx-proxy nginx -T
# Should show the full configuration (including defaults)
```

## Common Pitfalls and Solutions

### Pitfall 1: Wrong Proxy Host

**Symptom:** `502 Bad Gateway`

**Wrong:**
```nginx
proxy_pass http://localhost:3000;
```

**Why it fails:** `localhost` inside the Nginx container points to the container itself, not your host.

**Right:**
```nginx
proxy_pass http://nextjs:3000;
```

### Pitfall 2: Missing Proxy Headers

**Symptom:** Application receives requests but can't determine the original client IP

**Wrong:**
```nginx
proxy_pass http://nextjs:3000;
```

**Why it fails:** The application only sees the Nginx container's IP, not the real client.

**Right:**
```nginx
proxy_pass http://nextjs:3000;
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
```

### Pitfall 3: Wrong Port in Docker Compose

**Symptom:** `curl -v http://localhost:3000` fails

**Wrong:**
```yaml
ports:
  - "3001:3000"  # Maps host 3001 to container 3000
```

**Why it fails:** The host port mapping is wrong, so you can't access the app.

**Right:**
```yaml
ports:
  - "3000:3000"  # Maps host 3000 to container 3000
```

### Pitfall 4: Forgetting to Reload Nginx

**Symptom:** You changed the config but nothing happened

**Wrong:** 
```bash
# Just editing the file and assuming it works
vim nginx.conf
```

**Right:**
```bash
vim nginx.conf
docker exec nginx-proxy nginx -t  # Test first
docker exec nginx-proxy nginx -s reload  # Then reload
```

## Clean Up

When you're done with this part, you can shut everything down:

```bash
docker compose down

# To completely remove volumes and start fresh:
docker compose down -v
```

## What You've Learned

By completing Part 1, you can now:

- ✅ Define what a reverse proxy is and why you need one
- ✅ Distinguish reverse proxies from forward proxies
- ✅ Run Nginx in Docker with custom configuration
- ✅ Configure a basic `server` block with `listen` and `server_name`
- ✅ Use `location /` to match all routes
- ✅ Set `proxy_pass` to forward requests to an upstream service
- ✅ Understand why `127.0.0.1` doesn't work between containers
- ✅ Use Docker service names for inter-container communication
- ✅ Add essential proxy headers (`Host`, `X-Real-IP`, etc.)
- ✅ Test Nginx configuration with `nginx -t`
- ✅ Reload Nginx gracefully with `nginx -s reload`
- ✅ Read access and error logs to debug issues
- ✅ Verify that the proxy is working correctly

## Reference: Nginx Request Lifecycle (Deep Dive)

Understanding how Nginx processes a request helps you debug and configure effectively. Here's the simplified lifecycle:

### Phase 1: Connection Acceptance
- Nginx listens on configured ports (`listen 80`)
- Accepts incoming connections
- Each connection is assigned to a worker process

### Phase 2: Request Reading
- Nginx reads the HTTP request line (method, URI, version)
- Reads all headers
- **Does NOT** read the request body yet

### Phase 3: Server Selection
- Matches the `Host` header against `server_name` directives
- If no match, uses the default server (first one)

### Phase 4: Location Selection
- The URI is matched against `location` blocks
- Uses a priority system:
  1. Exact matches (`location = /`)
  2. Preferential prefix matches (`location ^~ /static/`)
  3. Regex matches (`location ~ \.php$`)
  4. Prefix matches (`location /`)

### Phase 5: Handler Execution
- For reverse proxy, the `proxy_pass` handler runs
- Nginx builds the upstream request
- Applies header transformations

### Phase 6: Upstream Connection
- Resolves the upstream hostname (DNS)
- Opens a connection
- Forwards the request

### Phase 7: Response Handling
- Receives the response from upstream
- May modify headers
- May buffer the response
- Sends to the client

### Phase 8: Logging
- After the response is complete, logs the request
- Access log contains the final status code
- Error log contains any errors encountered

## Reference: Complete `proxy_pass` Syntax

```nginx
proxy_pass http://upstream:port/uri;
```

- **`http://`**: Protocol (supports `https://` too)
- **`upstream`**: Hostname or IP address
- **`port`**: Port number
- **`/uri`**: Optional URI to append to the request

### Behavior with Trailing Slashes

| Nginx | Upstream | Result |
|-------|----------|--------|
| `proxy_pass http://nextjs:3000` | `/api/users` | `/api/users` |
| `proxy_pass http://nextjs:3000/` | `/api/users` | `/api/users` |
| `proxy_pass http://nextjs:3000/api` | `/v1/users` | `/api/v1/users` |
| `proxy_pass http://nextjs:3000/api/` | `/v1/users` | `/api/v1/users` |

Wait—the last two don't work that way. Actually:

| Nginx Location | Nginx proxy_pass | Client Request | Upstream Request |
|----------------|------------------|----------------|------------------|
| `/api/` | `http://nextjs:3000` | `/api/users` | `/api/users` |
| `/api/` | `http://nextjs:3000/` | `/api/users` | `/users` |
| `/api/` | `http://nextjs:3000/v1` | `/api/users` | `/v1/api/users` |
| `/api/` | `http://nextjs:3000/v1/` | `/api/users` | `/v1/users` |

**Rule:** The trailing slash in `proxy_pass` determines whether the location part is stripped.

We'll explore this in detail in Part 2.

## Next Steps

**Part 2: Path-Based Routing** builds on everything you've learned. You'll:

- Route different paths to different services (`/` → Next.js, `/api/` → FastAPI)
- Master the trailing-slash behavior
- Use `upstream` blocks for load balancing
- Create a polyglot microservices architecture with a single entry point

You already have the foundation. Let's keep building.
