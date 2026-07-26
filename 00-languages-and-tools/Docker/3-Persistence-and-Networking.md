# Part 3 – Persistence and Networking: Making Containers Talk and Remember

Containers are ephemeral by design—they're meant to be created, destroyed, and recreated without losing functionality. But what happens when you need to persist data? And how do containers communicate with each other? This part answers both questions.

By the end, you'll understand how to make containers remember data through volumes and talk to each other through Docker networks. You'll wire up a complete application stack with persistent storage and service discovery.

## 3.1 The Ephemeral Nature of Containers

### What "Ephemeral" Means

A container's filesystem is **ephemeral**—any data written to the container's writable layer disappears when the container is deleted.

```bash
# Run a container and create a file
docker run --name test-container ubuntu:22.04 bash -c "echo 'Important data' > /data.txt && cat /data.txt"
```
```
Important data
```

```bash
# Remove the container
docker rm test-container
```

```bash
# Run a new container from the same image - the data is gone
docker run --name test-container-new ubuntu:22.04 cat /data.txt
```
```
cat: /data.txt: No such file or directory
```

**Why this matters:** In production, you need databases to persist, user uploads to survive restarts, and logs to be retained. Docker solves this with **volumes**.

### The Three Data Storage Options

Docker provides three ways to manage data:

| Storage Type | Description | Use Case |
|--------------|-------------|----------|
| **Volumes** | Docker-managed storage | Production data persistence |
| **Bind Mounts** | Host directory mounted into container | Development hot-reloading |
| **tmpfs** | In-memory storage | Temporary cache, secrets |

Let's explore each in detail.

## 3.2 Volumes: Persistent Data Storage

Volumes are Docker's preferred mechanism for persisting data. They're fully managed by Docker and work across all platforms.

### Creating and Using Volumes

**Create a named volume:**
```bash
docker volume create my-app-data
```

**List volumes:**
```bash
docker volume ls
```
```
DRIVER    VOLUME NAME
local     my-app-data
```

**Inspect a volume:**
```bash
docker volume inspect my-app-data
```
```json
[
    {
        "CreatedAt": "2024-01-15T10:00:00Z",
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/var/lib/docker/volumes/my-app-data/_data",
        "Name": "my-app-data",
        "Options": {},
        "Scope": "local"
    }
]
```

### Using Volumes with Containers

**Mount a volume when running a container:**
```bash
# Mount using -v (verbose) syntax
docker run -d --name postgres-db -v my-app-data:/var/lib/postgresql/data postgres:15

# Mount using --mount (more explicit)
docker run -d --name postgres-db \
  --mount source=my-app-data,target=/var/lib/postgresql/data \
  postgres:15
```

**Now test persistence:**
```bash
# Create some data
docker exec postgres-db psql -U postgres -c "CREATE DATABASE testdb;"
```

```bash
# Stop and remove container
docker stop postgres-db
docker rm postgres-db
```

```bash
# Create new container with same volume
docker run -d --name postgres-db-new -v my-app-data:/var/lib/postgresql/data postgres:15
```

```bash
# Verify data survived
docker exec postgres-db-new psql -U postgres -c "\l"
```
```
                                  List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 testdb    | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
(4 rows)
```

### Anonymous Volumes

If you don't name a volume, Docker creates an anonymous one:
```bash
docker run -d --name temp -v /app/data nginx:alpine
```

```bash
docker volume ls
```
```
DRIVER    VOLUME NAME
local     0a1b2c3d4e5f6g7h8i9j0k...
local     my-app-data
```

Anonymous volumes are harder to manage. Use named volumes for production.

### Volume Drivers and Options

Volumes support different drivers for advanced use cases:

**NFS volume:**
```bash
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.100,rw \
  --opt device=:/path/to/share \
  nfs-share
```

**Amazon EBS:**
```bash
docker volume create --driver local \
  --opt type=ext4 \
  --opt device=/dev/xvdh \
  ebs-volume
```

### Backup and Restore Volumes

**Backup a volume:**
```bash
docker run --rm -v my-app-data:/source -v $(pwd):/backup ubuntu:22.04 \
  tar czf /backup/my-app-backup.tar.gz -C /source .
```

**Restore a volume:**
```bash
docker run --rm -v my-app-data:/target -v $(pwd):/backup ubuntu:22.04 \
  tar xzf /backup/my-app-backup.tar.gz -C /target
```

## 3.3 Bind Mounts: Development Superpower

Bind mounts mount a host directory directly into a container. They're essential for development workflows.

### The Development Use Case

**Without bind mounts (painful):**
1. Edit code
2. Rebuild image
3. Restart container
4. Wait

**With bind mounts (joyful):**
1. Edit code
2. See changes instantly (hot reload)

### Using Bind Mounts

**Basic bind mount:**
```bash
docker run -d --name dev-app \
  -v $(pwd):/app \
  -p 3000:3000 \
  node:18-alpine sh -c "cd /app && npm install && npm start"
```

**Important:** On Windows, use absolute paths:
```bash
docker run -d --name dev-app \
  -v "C:/projects/my-app:/app" \
  node:18-alpine sh -c "cd /app && npm install && npm start"
```

### Development Example: Python with Hot Reload

Create a simple Flask app with bind mounts:

**Project structure:**
```
flask-dev/
├── app.py
├── requirements.txt
└── Dockerfile.dev
```

**`app.py`:**
```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello from Flask!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
```

**`requirements.txt`:**
```
Flask==2.3.3
```

**`Dockerfile.dev`:**
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
EXPOSE 5000
CMD ["python", "app.py"]
```

**Run with bind mount:**
```bash
docker build -f Dockerfile.dev -t flask-dev .

# Run with bind mount for hot reload
docker run -d --name flask-app-dev \
  -v $(pwd):/app \
  -p 5000:5000 \
  flask-dev
```

**Test:**
```bash
curl http://localhost:5000
```

Now edit `app.py` and change the return message. The changes will be reflected without rebuilding the image.

### The Difference Between Volumes and Bind Mounts

| Feature | Volumes | Bind Mounts |
|---------|---------|-------------|
| **Management** | Docker manages | You manage |
| **Performance** | Fast | Fast (on Linux) |
| **Backup** | Docker commands | Standard filesystem |
| **Portability** | Yes (cross-platform) | No (path-dependent) |
| **Use Case** | Production data | Development code |

## 3.4 tmpfs Mounts: In-Memory Storage

tmpfs mounts store data in the container's memory, not on disk. They're useful for:
- Temporary caches
- Secrets (though better options exist)
- State that doesn't need to persist

**Using tmpfs:**
```bash
docker run -d --name cache \
  --tmpfs /tmp/cache:rw,noexec,nosuid,size=100M \
  nginx:alpine
```

```bash
# Check the mount
docker inspect cache --format='{{.GraphDriver.Data.MergedDir}}'
```

**Characteristics:**
- Data is lost on container restart
- Limited by container memory
- No disk I/O (faster than volumes)

## 3.5 Docker Networking Fundamentals

Now that containers can persist data, let's make them talk to each other.

### The Network Options

Docker provides these network drivers:

| Driver | Description | Use Case |
|--------|-------------|----------|
| **bridge** | Default, isolated network | Single-host containers |
| **host** | Uses host's network | Performance-critical |
| **none** | No networking | Highly secure containers |
| **overlay** | Multi-host networking | Swarm/Kubernetes |
| **macvlan** | Assign MAC addresses | Legacy systems |

### The Default Bridge Network

When Docker installs, it creates a default `bridge` network.

```bash
# List networks
docker network ls
```
```
NETWORK ID     NAME      DRIVER    SCOPE
abc123def456   bridge    bridge    local
def456ghi789   host      host      local
ghi789jkl012   none      null      local
```

**Limitations of the default bridge:**
- No DNS resolution between containers
- Containers can only communicate by IP
- Manual `--link` needed (deprecated)
- Security: containers can talk to each other by default

### User-Defined Bridge Networks

User-defined bridge networks are better because:
- **DNS resolution**: Containers can reach each other by name
- **Better isolation**: Only containers on the same network can communicate
- **Automatic cleanup**: Removed when network is removed

## 3.6 Creating and Using User-Defined Networks

### Create a Network

```bash
docker network create app-network
```

```bash
docker network ls
```
```
NETWORK ID     NAME           DRIVER    SCOPE
abc123def456   bridge         bridge    local
def456ghi789   host           host      local
ghi789jkl012   none           null      local
jkl012mno345   app-network    bridge    local
```

### Connect Containers to a Network

**Method 1: Specify network at creation:**
```bash
docker run -d --name api-app --network app-network api-image:1.0
docker run -d --name db-app --network app-network postgres:15
```

**Method 2: Connect existing container:**
```bash
docker network connect app-network api-app
```

### DNS Resolution in Action

Let's see the magic of DNS-based service discovery:

```bash
# Create network
docker network create app-network

# Run a Redis container
docker run -d --name redis-cache --network app-network redis:alpine

# Run a container that can ping redis by name
docker run --rm --network app-network alpine:3.18 sh -c "ping -c 2 redis-cache"
```
```
PING redis-cache (172.18.0.2): 56 data bytes
64 bytes from 172.18.0.2: seq=0 ttl=64 time=0.113 ms
64 bytes from 172.18.0.2: seq=1 ttl=64 time=0.104 ms
```

**Notice:** The container resolved `redis-cache` to its IP address automatically!

### Testing the Network

**Full stack example:**

```bash
# Create network
docker network create web-stack

# Run PostgreSQL
docker run -d --name postgres \
  --network web-stack \
  -e POSTGRES_PASSWORD=secret \
  -v pg-data:/var/lib/postgresql/data \
  postgres:15

# Run Redis
docker run -d --name redis \
  --network web-stack \
  redis:alpine

# Run application that connects to both
docker run -d --name app \
  --network web-stack \
  -p 8080:80 \
  -e DB_HOST=postgres \
  -e REDIS_HOST=redis \
  your-app-image:1.0
```

**The app can now connect to:**
- `postgres:5432` (database)
- `redis:6379` (cache)

## 3.7 Network Inspection and Troubleshooting

### Inspecting Networks

```bash
# Detailed network info
docker network inspect app-network
```

```json
[
    {
        "Name": "app-network",
        "Id": "abc123def456...",
        "Created": "2024-01-15T10:00:00Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Config": [
                {
                    "Subnet": "172.18.0.0/16",
                    "Gateway": "172.18.0.1"
                }
            ]
        },
        "Containers": {
            "redis-cache": {
                "Name": "redis-cache",
                "EndpointID": "...",
                "MacAddress": "02:42:ac:12:00:02",
                "IPv4Address": "172.18.0.2/16",
                "IPv6Address": ""
            }
        }
    }
]
```

### Entering a Container on a Network

```bash
# Execute a shell in the container with network access
docker exec -it redis-cache sh

# Inside the container, check DNS
nslookup redis-cache
```
```
Server:         127.0.0.11
Address:        127.0.0.11:53

Non-authoritative answer:
Name:   redis-cache
Address: 172.18.0.2
```

### Common Networking Issues

**Issue: Containers can't reach each other**
```bash
# Check containers are on the same network
docker inspect container1 --format='{{.NetworkSettings.Networks}}'
docker inspect container2 --format='{{.NetworkSettings.Networks}}'
```

**Issue: Port conflict**
```bash
# Check what's using the port
docker ps --filter "publish=8080"
lsof -i :8080  # On Linux/Mac
```

**Issue: DNS not working**
```bash
# Check the network's DNS settings
docker network inspect app-network | grep -A 5 "IPAM"
```

## 3.8 The Host Network and None Network

### Host Network

`host` mode makes the container use the host's network stack directly.

```bash
docker run -d --name host-network --network host nginx:alpine
```

**Pros:**
- No network overhead (better performance)
- No port mapping needed

**Cons:**
- No network isolation
- Port conflicts with host services
- Not portable

### None Network

`none` mode gives the container its own network namespace but no network interfaces.

```bash
docker run -d --name isolated --network none nginx:alpine
```

**Use case:** Highly secure containers that don't need network access.

## 3.9 Complete Lab: Multi-Tier Application with Persistence and Networking

Let's build a complete application that demonstrates everything we've learned.

### Project Structure

```
three-tier-app/
├── backend/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/
│   ├── index.html
│   └── Dockerfile
├── docker-compose.yml    (we'll build this in Part 4)
└── README.md
```

### Step 1: The Backend API

**`backend/app.py`:**
```python
#!/usr/bin/env python3
"""
A REST API that tracks visits using Redis
"""
from flask import Flask, jsonify
import redis
import os
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Connect to Redis using the service name
redis_host = os.getenv('REDIS_HOST', 'localhost')
redis_client = redis.Redis(host=redis_host, port=6379, decode_responses=True)

@app.route('/')
def index():
    """Simple welcome endpoint"""
    return jsonify({
        'service': 'backend-api',
        'status': 'running',
        'version': '1.0.0'
    })

@app.route('/visit')
def visit():
    """Increment and return visit count"""
    try:
        visits = redis_client.incr('visits')
        logger.info(f'Visit count: {visits}')
        return jsonify({
            'visits': visits,
            'message': 'Hello from the API!'
        })
    except redis.ConnectionError:
        logger.error('Redis connection failed')
        return jsonify({
            'error': 'Database connection failed'
        }), 503

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'redis': 'connected' if redis_client.ping() else 'disconnected'
    })

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
```

**`backend/requirements.txt`:**
```
Flask==2.3.3
redis==5.0.1
```

**`backend/Dockerfile`:**
```dockerfile
# Multi-stage build for the backend
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY app.py .
ENV PATH=/root/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1

RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 --no-create-home appuser
USER appuser

HEALTHCHECK --interval=30s --timeout=3s \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

EXPOSE 5000
CMD ["python", "app.py"]
```

### Step 2: The Frontend

**`frontend/index.html`:**
```html
<!DOCTYPE html>
<html>
<head>
    <title>Docker Demo App</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: #f0f0f0;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        button {
            background: #4CAF50;
            color: white;
            border: none;
            padding: 10px 20px;
            font-size: 16px;
            border-radius: 5px;
            cursor: pointer;
        }
        button:hover { background: #45a049; }
        #result {
            margin-top: 20px;
            padding: 15px;
            background: #e7f3fe;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🐳 Docker Demo Application</h1>
        <p>This app uses a frontend, backend API, and Redis database.</p>
        
        <button onclick="callAPI()">Click me to visit!</button>
        
        <div id="result">
            <p>Visits: <span id="visits">0</span></p>
            <p id="message">Click the button above</p>
        </div>
        
        <div id="status">
            <h3>System Status</h3>
            <p>Backend: <span id="backend-status">Checking...</span></p>
        </div>
    </div>

    <script>
        // Check backend health
        fetch('http://localhost:5000/health')
            .then(res => res.json())
            .then(data => {
                document.getElementById('backend-status').textContent = 
                    data.status === 'healthy' ? '✅ Healthy' : '❌ Unhealthy';
            })
            .catch(() => {
                document.getElementById('backend-status').textContent = '❌ Unreachable';
            });

        // Call the visit endpoint
        function callAPI() {
            fetch('http://localhost:5000/visit')
                .then(res => res.json())
                .then(data => {
                    document.getElementById('visits').textContent = data.visits || 0;
                    document.getElementById('message').textContent = data.message || 'Error';
                })
                .catch(err => {
                    document.getElementById('message').textContent = 'Error: ' + err.message;
                });
        }
    </script>
</body>
</html>
```

**`frontend/Dockerfile`:**
```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
```

### Step 3: Run the Stack with Manual Commands

Now let's run everything using the Docker commands we've learned:

```bash
# 1. Create the network
docker network create three-tier

# 2. Create a volume for Redis persistence
docker volume create redis-data

# 3. Run Redis
docker run -d --name redis \
  --network three-tier \
  -v redis-data:/data \
  redis:alpine redis-server --appendonly yes

# 4. Build and run the backend
cd backend
docker build -t backend-api:1.0 .
docker run -d --name backend \
  --network three-tier \
  -e REDIS_HOST=redis \
  -p 5000:5000 \
  backend-api:1.0

# 5. Build and run the frontend
cd ../frontend
docker build -t frontend:1.0 .
docker run -d --name frontend \
  --network three-tier \
  -p 8080:80 \
  frontend:1.0

# 6. Test the stack
curl http://localhost:5000/health
curl http://localhost:5000/visit
curl http://localhost:5000/visit

# 7. Open browser to http://localhost:8080
```

### Step 4: Verify Everything Works

**Check container status:**
```bash
docker ps
```

**Check network connections:**
```bash
docker network inspect three-tier
```

**Check Redis data:**
```bash
docker exec redis redis-cli get visits
```
```
"5"  # Should show the number of visits
```

**Check backend logs:**
```bash
docker logs backend
```

**Check connectivity between containers:**
```bash
docker exec backend ping -c 2 redis
```

### Step 5: Test Persistence

```bash
# Stop and remove Redis
docker stop redis
docker rm redis

# Start Redis again with the volume
docker run -d --name redis \
  --network three-tier \
  -v redis-data:/data \
  redis:alpine redis-server --appendonly yes

# Check if data persists
docker exec redis redis-cli get visits
```
```
"5"  # Data should still be there!
```

## 3.10 Advanced Networking: Custom Bridge Configuration

### Custom IP Ranges

```bash
docker network create \
  --subnet=192.168.100.0/24 \
  --gateway=192.168.100.1 \
  custom-network
```

### Static IPs for Containers

```bash
docker run -d --name static-ip \
  --network custom-network \
  --ip 192.168.100.50 \
  nginx:alpine
```

### Network Aliases

```bash
docker run -d --name api-v1 \
  --network three-tier \
  --network-alias api \
  backend-api:1.0
```

Now other containers can reach this container via `api` as well as `api-v1`.

## 3.11 Cleanup

```bash
# Stop all containers
docker stop frontend backend redis

# Remove containers
docker rm frontend backend redis

# Remove network
docker network rm three-tier

# Remove volume
docker volume rm redis-data

# Or remove everything at once
docker system prune -a --volumes
```

## 3.12 Summary

You've now mastered the two essential pillars of containerized applications:

**Persistence (Volumes):**
- ✅ Named volumes for production data
- ✅ Bind mounts for development
- ✅ tmpfs for ephemeral storage
- ✅ Backup and restore strategies

**Networking:**
- ✅ User-defined bridge networks
- ✅ DNS-based service discovery
- ✅ Container communication by name
- ✅ Network isolation and security

**Mental Models:**
- **Data persistence**: Container data is ephemeral by default. Use volumes to make it durable.
- **Service discovery**: On user-defined networks, containers can reach each other by container name.
- **Network isolation**: Only containers on the same network can communicate.

**Ready for Part 4!** Now that you understand how individual containers work with data and networking, you're ready to orchestrate them as a complete system with Docker Compose.
