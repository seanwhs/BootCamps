# DOCKER MASTERY: CONTAINERIZE ANYTHING FROM ZERO TO PRODUCTION

## Student Workbook

---

**Purpose:** This workbook accompanies the Docker Mastery series. It provides structured exercises, checkpoints, and reflection questions to reinforce learning. Complete each section as you progress through the series.

**How to Use:**
1. Read the corresponding part of the series
2. Complete the exercises in this workbook
3. Verify your work using the provided checkpoints
4. Answer reflection questions to solidify understanding

**Estimated Time:** 20-30 hours total

---

---

# PART 0: INTRODUCTION

## Pre-Assessment

---

**Before You Begin**

Rate your confidence level (1-5) for each topic:

| Topic | Rating (1-5) |
|-------|--------------|
| Using the command line | ___ |
| Understanding web applications | ___ |
| Installing software on your computer | ___ |
| Running programs from the terminal | ___ |
| Understanding what a "server" is | ___ |
| Deploying applications | ___ |

---

**Your Goals:**

What do you hope to achieve by completing this series?

1. _________________________________________________

2. _________________________________________________

3. _________________________________________________

---

**Your Background:**

What programming languages do you know? _________________

What operating systems do you use? _________________

Have you used Docker before? If yes, describe your experience:

_________________________________________________

---

---

# PART 1: CORE FOUNDATION

## Exercise 1.1: Installing Docker

---

**Instructions:** Follow the installation instructions for your operating system. Verify your installation.

**Checkpoint:**

```bash
# Run this command and record the output
docker --version
```

**Output:** _________________________________________________

---

```bash
# Run this command and record the output
docker run hello-world
```

**Output (copy the welcome message):**

_________________________________________________

_________________________________________________

_________________________________________________

---

**Troubleshooting:** If you encountered any issues during installation, describe them and how you resolved them.

_________________________________________________

_________________________________________________

---

---

## Exercise 1.2: Your First Container

---

**Instructions:** Run your first interactive container.

```bash
docker run -it ubuntu:22.04 bash
```

**Inside the container, complete these tasks:**

1. Check the hostname:
```bash
hostname
```
**Output:** _________________

2. Check the operating system:
```bash
cat /etc/os-release
```
**Output (copy the version):** _________________

3. List the processes:
```bash
ps aux
```
**How many processes do you see?** _________________

4. Exit the container:
```bash
exit
```

---

**Question:** Why did the container stop when you exited?

_________________________________________________

_________________________________________________

---

---

## Exercise 1.3: Running a Web Server

---

**Instructions:** Run an Nginx web server in the background.

```bash
docker run -d --name my-web -p 8080:80 nginx:alpine
```

**Checkpoint:**

1. Verify the container is running:
```bash
docker ps
```
**Copy the output:**

_________________________________________________

_________________________________________________

2. Open your browser to `http://localhost:8080`

**What do you see?** _________________________________________________

3. View the logs:
```bash
docker logs my-web
```
**Copy the last few lines:**

_________________________________________________

_________________________________________________

---

**Stop and remove the container:**

```bash
docker stop my-web
docker rm my-web
```

---

---

## Exercise 1.4: Container Lifecycle

---

**Instructions:** Practice the full container lifecycle.

1. Create a container:
```bash
docker run -d --name lifecycle nginx:alpine
```

2. Check it's running:
```bash
docker ps
```
**Is it running?** _______

3. Pause the container:
```bash
docker pause lifecycle
```

4. Check the status:
```bash
docker ps
```
**What's the status?** _________________________________________________

5. Unpause:
```bash
docker unpause lifecycle
```

6. Stop the container:
```bash
docker stop lifecycle
```

7. Check status:
```bash
docker ps -a
```
**What's the status now?** _________________________________________________

8. Start it again:
```bash
docker start lifecycle
```

9. Remove it:
```bash
docker rm -f lifecycle
```

---

**Question:** What's the difference between `docker stop` and `docker kill`?

_________________________________________________

_________________________________________________

---

---

## Exercise 1.5: Inspection Commands

---

**Instructions:** Run a container and inspect it.

```bash
docker run -d --name inspect-me nginx:alpine
```

**Tasks:**

1. Get the container's IP address:
```bash
docker inspect inspect-me --format='{{.NetworkSettings.IPAddress}}'
```
**IP Address:** _________________

2. Get the container's status:
```bash
docker inspect inspect-me --format='{{.State.Status}}'
```
**Status:** _________________

3. Get the container's name:
```bash
docker inspect inspect-me --format='{{.Name}}'
```
**Name:** _________________

4. View the full inspect output:
```bash
docker inspect inspect-me
```
**What's one interesting piece of information you found?**

_________________________________________________

5. Check resource usage:
```bash
docker stats inspect-me --no-stream
```
**Record the memory usage:** _________________

---

**Clean up:**

```bash
docker rm -f inspect-me
```

---

---

## Part 1 Reflection Questions

---

1. What is the difference between a container and a virtual machine?

_________________________________________________

_________________________________________________

_________________________________________________

2. What are namespaces and cgroups? Why are they important for containers?

_________________________________________________

_________________________________________________

_________________________________________________

3. What is the difference between an image and a container?

_________________________________________________

_________________________________________________

_________________________________________________

4. Why do containers exit immediately sometimes?

_________________________________________________

_________________________________________________

---

---

# PART 2: CUSTOM IMAGES

## Exercise 2.1: Your First Dockerfile

---

**Instructions:** Create a simple web application and Dockerfile.

**Step 1: Create the application:**

Create a file called `app.py`:

```python
from http.server import HTTPServer, BaseHTTPRequestHandler

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'Hello from Docker!')

if __name__ == '__main__':
    server = HTTPServer(('', 8000), Handler)
    print('Server running on port 8000')
    server.serve_forever()
```

**Step 2: Create a Dockerfile:**

Create a file called `Dockerfile`:

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY app.py .
CMD ["python", "app.py"]
```

---

**Build and run:**

```bash
docker build -t my-first-app .
docker run -d --name app1 -p 8000:8000 my-first-app
```

**Checkpoint:**

```bash
curl http://localhost:8000
```
**Output:** _________________

```bash
docker logs app1
```
**Output:** _________________

---

---

## Exercise 2.2: Optimize the Dockerfile

---

**Instructions:** The Dockerfile from Exercise 2.1 works but can be improved. Let's optimize it.

**Current Dockerfile:**
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY app.py .
CMD ["python", "app.py"]
```

**Problems:**
1. No non-root user
2. No .dockerignore file
3. No health check
4. Not using multi-stage builds

---

**Create an optimized Dockerfile:**

```dockerfile
FROM python:3.11-slim

# Create non-root user
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 --no-create-home appuser

WORKDIR /app

# Copy application
COPY --chown=appuser:appgroup app.py .

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000')" || exit 1

CMD ["python", "app.py"]
```

**Build and test:**

```bash
docker build -t my-app-optimized .
docker run -d --name app2 -p 8001:8000 my-app-optimized
```

**Checkpoints:**

1. Check the user:
```bash
docker exec app2 whoami
```
**Output:** _________________

2. Check the health status:
```bash
docker inspect app2 --format='{{.State.Health.Status}}'
```
**Output:** _________________

---

---

## Exercise 2.3: Multi-Stage Build

---

**Instructions:** Create a multi-stage build for a more complex application.

**Step 1: Create a Python app with dependencies:**

`requirements.txt`:
```
Flask==2.3.3
```

`app.py`:
```python
from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def index():
    return jsonify({
        'message': 'Hello from Flask!',
        'hostname': os.getenv('HOSTNAME', 'unknown')
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

---

**Step 2: Create a multi-stage Dockerfile:**

```dockerfile
# Stage 1: Builder
FROM python:3.11-slim AS builder

WORKDIR /app
COPY requirements.txt .

# Install dependencies
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim

WORKDIR /app

# Copy dependencies from builder
COPY --from=builder /root/.local /root/.local

# Copy application
COPY app.py .

# Set PATH
ENV PATH=/root/.local/bin:$PATH

# Create non-root user
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 --no-create-home appuser

USER appuser

EXPOSE 5000
CMD ["python", "app.py"]
```

---

**Build and compare:**

```bash
docker build -t flask-app-multi .
docker images | grep flask-app-multi
```
**Record the size:** _________________

**Compare to a single-stage build:**

```dockerfile
# Single-stage (for comparison)
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app.py .
CMD ["python", "app.py"]
```

```bash
docker build -t flask-app-single -f Dockerfile.single .
docker images | grep flask-app-
```

**Which is smaller?** _________________

---

---

## Exercise 2.4: .dockerignore

---

**Instructions:** Create a .dockerignore file.

**Step 1: Create a .dockerignore file:**

```
# Version control
.git/
.gitignore

# Python cache
__pycache__/
*.pyc
*.pyo

# IDE files
.vscode/
.idea/

# OS files
.DS_Store
Thumbs.db

# Secrets
.env
*.key
*.pem

# Build outputs
dist/
build/

# Documentation
*.md
docs/
```

---

**Step 2: Test the .dockerignore:**

```bash
# Build with .dockerignore
docker build -t test-ignore .

# Check what was copied
docker run --rm test-ignore ls -la /app
```

---

**Question:** What files would be excluded from the build context?

_________________________________________________

_________________________________________________

---

---

## Part 2 Reflection Questions

---

1. Why is it important to order instructions in a Dockerfile from least-changing to most-changing?

_________________________________________________

_________________________________________________

2. What are the benefits of multi-stage builds?

_________________________________________________

_________________________________________________

3. Why should you run containers as a non-root user?

_________________________________________________

_________________________________________________

4. What is the purpose of a .dockerignore file?

_________________________________________________

_________________________________________________

---

---

# PART 3: PERSISTENCE AND NETWORKING

## Exercise 3.1: Named Volumes

---

**Instructions:** Create and use named volumes for persistent data.

**Step 1: Create a volume:**
```bash
docker volume create my-data
```

**Step 2: Use the volume:**
```bash
docker run -d --name vol-test -v my-data:/data alpine sleep 300
```

**Step 3: Write data:**
```bash
docker exec vol-test sh -c "echo 'Hello Docker' > /data/hello.txt"
```

**Step 4: Verify:**
```bash
docker exec vol-test cat /data/hello.txt
```
**Output:** _________________

**Step 5: Remove the container:**
```bash
docker rm -f vol-test
```

**Step 6: Create a new container with the same volume:**
```bash
docker run -d --name vol-test2 -v my-data:/data alpine sleep 300
```

**Step 7: Verify data persists:**
```bash
docker exec vol-test2 cat /data/hello.txt
```
**Output:** _________________

---

**Checkpoint:** Data persisted even though the container was removed!

---

---

## Exercise 3.2: Bind Mounts

---

**Instructions:** Use bind mounts for development.

**Step 1: Create a local directory:**
```bash
mkdir -p dev-app
cd dev-app
```

**Step 2: Create a simple HTML file:**
```bash
echo '<h1>Hello from Bind Mount!</h1>' > index.html
```

**Step 3: Run Nginx with bind mount:**
```bash
docker run -d --name dev-nginx -p 8080:80 -v $(pwd):/usr/share/nginx/html nginx:alpine
```

**Step 4: Open browser to http://localhost:8080**

**What do you see?** _________________________________________________

**Step 5: Edit the file:**
```bash
echo '<h1>Updated Content!</h1>' > index.html
```

**Step 6: Refresh the browser**

**What changed?** _________________________________________________

---

**Question:** Why is this useful for development?

_________________________________________________

---

---

## Exercise 3.3: User-Defined Network

---

**Instructions:** Create a user-defined network and connect containers.

**Step 1: Create a network:**
```bash
docker network create app-net
```

**Step 2: Run containers on the network:**
```bash
docker run -d --name redis --network app-net redis:alpine
docker run -d --name api --network app-net nginx:alpine
```

**Step 3: Test connectivity:**
```bash
docker exec api ping redis
```
**Does it work?** _______

**Step 4: Test DNS resolution:**
```bash
docker exec api nslookup redis
```
**IP Address:** _________________

**Step 5: Test from default bridge:**
```bash
docker run --rm alpine ping redis
```
**Does it work?** _______

**Why?** _________________________________________________

---

---

## Exercise 3.4: Complete Three-Tier Stack

---

**Instructions:** Wire up a complete three-tier stack manually.

**Step 1: Create network:**
```bash
docker network create three-tier
```

**Step 2: Run PostgreSQL:**
```bash
docker volume create pg-data
docker run -d --name postgres \
  --network three-tier \
  -v pg-data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=secret \
  postgres:15
```

**Step 3: Run Redis:**
```bash
docker volume create redis-data
docker run -d --name redis \
  --network three-tier \
  -v redis-data:/data \
  redis:alpine redis-server --appendonly yes
```

**Step 4: Create a simple Python app that connects to both:**

`app.py`:
```python
import redis
import psycopg2
import os

# Connect to Redis
r = redis.Redis(host='redis', port=6379)
r.ping()
print("Connected to Redis")

# Connect to PostgreSQL
conn = psycopg2.connect(
    host='postgres',
    user='postgres',
    password='secret',
    dbname='postgres'
)
print("Connected to PostgreSQL")

print("All services connected!")
```

**Step 5: Run the application:**
```bash
docker run --rm \
  --network three-tier \
  -v $(pwd):/app \
  python:3.11-slim \
  python /app/app.py
```

**Expected output:**
```
Connected to Redis
Connected to PostgreSQL
All services connected!
```

---

**Clean up:**

```bash
docker rm -f postgres redis
docker volume rm pg-data redis-data
docker network rm three-tier
```

---

---

## Part 3 Reflection Questions

---

1. What's the difference between a volume and a bind mount? When would you use each?

_________________________________________________

_________________________________________________

_________________________________________________

2. Why is DNS resolution important in Docker networking?

_________________________________________________

_________________________________________________

_________________________________________________

3. How do containers on a user-defined bridge network communicate differently from those on the default bridge?

_________________________________________________

_________________________________________________

_________________________________________________

4. Why are containers considered "ephemeral"? How do volumes solve this?

_________________________________________________

_________________________________________________

---

---

# PART 4: DOCKER COMPOSE

## Exercise 4.1: Convert to Compose

---

**Instructions:** Convert the three-tier stack from Part 3 to Docker Compose.

**Create `docker-compose.yml`:**

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=secret
    volumes:
      - pg-data:/var/lib/postgresql/data
    networks:
      - three-tier
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:alpine
    command: redis-server --appendonly yes
    volumes:
      - redis-data:/data
    networks:
      - three-tier
    restart: unless-stopped

  app:
    image: python:3.11-slim
    volumes:
      - ./app.py:/app/app.py
    working_dir: /app
    command: python app.py
    networks:
      - three-tier
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_started
    restart: unless-stopped

volumes:
  pg-data:
  redis-data:

networks:
  three-tier:
```

---

**Start the stack:**
```bash
docker compose up -d
```

**Check status:**
```bash
docker compose ps
```

**Check logs:**
```bash
docker compose logs app
```

**Stop and clean up:**
```bash
docker compose down -v
```

---

---

## Exercise 4.2: Environment Variables

---

**Instructions:** Use environment variables for configuration.

**Step 1: Create `.env` file:**

```
POSTGRES_PASSWORD=supersecret
POSTGRES_USER=appuser
POSTGRES_DB=appdb
```

**Step 2: Update `docker-compose.yml`:**

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
    volumes:
      - pg-data:/var/lib/postgresql/data
    networks:
      - three-tier
```

---

**Test:**

```bash
# Start with environment variables
docker compose up -d

# Verify the variables
docker compose exec postgres env | grep POSTGRES
```

**Question:** Why is using environment variables better than hardcoding values in the compose file?

_________________________________________________

_________________________________________________

---

---

## Exercise 4.3: Development Profile

---

**Instructions:** Add a development profile with hot reload.

**Create `docker-compose.override.yml`:**

```yaml
version: '3.8'

services:
  app:
    build:
      context: ./app
      dockerfile: Dockerfile.dev
    volumes:
      - ./app:/app  # Mount for hot reload
      - /app/__pycache__  # Ignore cache
    environment:
      - FLASK_DEBUG=1
    command: python -m flask run --host=0.0.0.0 --port=5000 --reload
    ports:
      - "5000:5000"

  # Development-only services
  adminer:
    image: adminer:latest
    ports:
      - "8081:8080"
    networks:
      - three-tier
    profiles:
      - dev-tools
```

---

**Create `Dockerfile.dev`:**
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
CMD ["python", "app.py"]
```

---

**Start with development profile:**
```bash
docker compose --profile dev-tools up -d
```

**Check all services:**
```bash
docker compose ps
```

---

---

## Exercise 4.4: Docker Compose Lab

---

**Instructions:** Create a complete development environment with hot reload.

**Step 1: Project Structure:**

```
compose-lab/
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile.dev
├── docker-compose.yml
└── .env
```

**Step 2: Application Files:**

`app/app.py`:
```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello from Flask!'

@app.route('/health')
def health():
    return {'status': 'healthy'}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

`app/requirements.txt`:
```
Flask==2.3.3
```

---

`app/Dockerfile.dev`:
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
CMD ["python", "app.py"]
```

**Step 3: Compose File:**

`docker-compose.yml`:
```yaml
version: '3.8'

services:
  app:
    build:
      context: ./app
      dockerfile: Dockerfile.dev
    volumes:
      - ./app:/app
    ports:
      - "5000:5000"
    environment:
      - FLASK_ENV=development
    restart: unless-stopped
```

---

**Test the development environment:**

1. Start: `docker compose up -d`
2. Edit `app/app.py` and change the message
3. Refresh browser to see changes
4. Check health: `curl http://localhost:5000/health`

---

---

## Part 4 Reflection Questions

---

1. What is the benefit of using Docker Compose over manual `docker run` commands?

_________________________________________________

_________________________________________________

_________________________________________________

2. How do environment variables improve your Compose configuration?

_________________________________________________

_________________________________________________

_________________________________________________

3. What is the purpose of `depends_on`? What are its limitations?

_________________________________________________

_________________________________________________

_________________________________________________

4. How do profiles help manage different environments?

_________________________________________________

_________________________________________________

---

---

# PART 5: PRODUCTION READINESS

## Exercise 5.1: Security Hardening

---

**Instructions:** Take an insecure container and harden it.

**Insecure Dockerfile:**

```dockerfile
FROM ubuntu:latest
RUN apt-get update && apt-get install -y python3
COPY app.py /app.py
CMD ["python3", "/app.py"]
```

**Problems to fix:**
1. Running as root
2. Using `latest` tag
3. No non-root user
4. No health check
5. No resource limits
6. Large base image

---

**Create a secure Dockerfile:**

```dockerfile
FROM python:3.11-slim

# Create non-root user
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 --no-create-home appuser

WORKDIR /app

# Copy application
COPY app.py .

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

CMD ["python", "app.py"]
```

---

**Secure run command:**

```bash
docker run -d \
  --name secure-app \
  --read-only \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  --security-opt no-new-privileges:true \
  --memory=256M \
  --cpus=0.5 \
  --user 1001:1001 \
  secure-app
```

---

**Verify security:**

```bash
# Check user
docker exec secure-app whoami

# Check read-only
docker exec secure-app touch /test.txt

# Check capabilities
docker inspect secure-app --format='{{.HostConfig.CapDrop}}'

# Check limits
docker inspect secure-app --format='{{.HostConfig.Memory}}'
```

---

---

## Exercise 5.2: Health Checks

---

**Instructions:** Add health checks to your services.

**`docker-compose.yml` with health checks:**

```yaml
version: '3.8'

services:
  app:
    build: ./app
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s
    depends_on:
      postgres:
        condition: service_healthy

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=secret
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

  redis:
    image: redis:alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5
```

---

**Test health checks:**
```bash
docker compose up -d
docker compose ps
docker inspect app --format='{{.State.Health.Status}}'
```

---

---

## Exercise 5.3: Resource Limits

---

**Instructions:** Add resource limits to your services.

**`docker-compose.yml` with resources:**

```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M

  postgres:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G

  redis:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
        reservations:
          cpus: '0.25'
          memory: 128M
```

---

**Test limits:**
```bash
docker compose up -d
docker stats
```

**Question:** Why are resource limits important in production?

_________________________________________________

_________________________________________________

---

---

## Exercise 5.4: Logging Configuration

---

**Instructions:** Configure production logging.

**`docker-compose.yml` logging:**

```yaml
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        compress: "true"
        tag: "{{.Name}}/{{.ID}}"

  postgres:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        compress: "true"
```

---

**Test logging:**
```bash
docker compose up -d
docker compose logs app

# Check log files
docker exec app ls -la /var/log/  # Depends on application
```

---

---

## Part 5 Reflection Questions

---

1. List at least 5 security best practices for production containers.

_________________________________________________

_________________________________________________

_________________________________________________

_________________________________________________

_________________________________________________

2. Why are health checks important? What happens when a container fails a health check?

_________________________________________________

_________________________________________________

_________________________________________________

3. What is a noisy neighbor problem? How do resource limits prevent it?

_________________________________________________

_________________________________________________

_________________________________________________

4. Why is logging to stdout/stderr a best practice?

_________________________________________________

_________________________________________________

---

---

# PART 6: DEBUGGING AND OPERATIONS

## Exercise 6.1: Debugging Practice

---

**Instructions:** Debug a broken container setup.

**Broken setup:**

```yaml
version: '3.8'

services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    depends_on:
      - app

  app:
    build: ./app
    environment:
      - DB_HOST=db
    depends_on:
      - db

  db:
    image: postgres
    environment:
      - POSTGRES_DB=app
    volumes:
      - ./data:/var/lib/postgresql/data
```

---

**Debugging Tasks:**

1. Start the broken stack:
```bash
docker compose up -d
docker compose ps
```

**What's broken?** _________________________________________________

2. Check logs:
```bash
docker compose logs app
```

**What's the error?** _________________________________________________

3. Fix the issues (hints: missing requirements, user, health checks)

---

**Write the fixed `docker-compose.yml`:**

_________________________________________________

_________________________________________________

_________________________________________________

_________________________________________________

---

---

## Exercise 6.2: Inspect and Troubleshoot

---

**Instructions:** Use inspection commands to debug.

**Create a problematic container:**
```bash
docker run -d --name problem \
  -p 8080:80 \
  -v $(pwd):/app \
  nginx:alpine
```

**Tasks:**

1. Check if it's running:
```bash
docker ps
```

2. View logs:
```bash
docker logs problem
```

3. Inspect the container:
```bash
docker inspect problem
```
**Record the IP address:** _________________

4. Check mounted volumes:
```bash
docker inspect problem --format='{{.Mounts}}'
```

5. Enter the container:
```bash
docker exec -it problem /bin/sh
```

6. Check processes inside:
```bash
docker top problem
```

---

---

## Exercise 6.3: Performance Optimization

---

**Instructions:** Optimize a slow-building Dockerfile.

**Slow Dockerfile:**

```dockerfile
FROM node:18

WORKDIR /app

COPY . .

RUN npm install
RUN npm run build

EXPOSE 3000
CMD ["node", "dist/server.js"]
```

**Problems:**
1. Copying everything before installing dependencies
2. No .dockerignore
3. Not using multi-stage builds
4. No cache optimization
5. Large base image

---

**Write an optimized Dockerfile:**

_________________________________________________

_________________________________________________

_________________________________________________

_________________________________________________

_________________________________________________

_________________________________________________

---

**Test the optimization:**

```bash
# Time the build
time docker build -t optimized .

# Check size
docker images optimized
```

---

---

## Part 6 Reflection Questions

---

1. What's your systematic approach to debugging a failing container?

_________________________________________________

_________________________________________________

_________________________________________________

2. What commands do you use most often when troubleshooting?

_________________________________________________

_________________________________________________

_________________________________________________

3. How can you tell if a container is out of memory?

_________________________________________________

_________________________________________________

_________________________________________________

4. What's the benefit of optimizing build times?

_________________________________________________

_________________________________________________

---

---

# PART 7: SECURITY AND REGISTRIES

## Exercise 7.1: Image Signing with Cosign

---

**Instructions:** Sign and verify container images.

**Step 1: Install Cosign**

```bash
# macOS
brew install sigstore/tap/cosign

# Linux
curl -LO https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64
chmod +x cosign-linux-amd64
sudo mv cosign-linux-amd64 /usr/local/bin/cosign
```

**Step 2: Generate keys**
```bash
cosign generate-key-pair
```
**Record where keys are stored:** _________________

**Step 3: Build and push image**
```bash
docker build -t myapp:1.0 .
docker tag myapp:1.0 myregistry/myapp:1.0
docker push myregistry/myapp:1.0
```

**Step 4: Sign the image**
```bash
cosign sign --key cosign.key myregistry/myapp:1.0
```

**Step 5: Verify**
```bash
cosign verify --key cosign.pub myregistry/myapp:1.0
```

**Does it verify?** _______

---

---

## Exercise 7.2: SBOM Generation

---

**Instructions:** Generate a Software Bill of Materials.

**Install Syft:**
```bash
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
```

**Generate SBOM:**
```bash
syft myapp:1.0 -o spdx-json > sbom.json
```

**Examine the SBOM:**
```bash
cat sbom.json | jq '.packages | length'
```
**How many packages?** _________________

**View first package:**
```bash
cat sbom.json | jq '.packages[0]'
```

**Question:** Why is an SBOM important for security?

_________________________________________________

_________________________________________________

---

---

## Exercise 7.3: Vulnerability Scanning

---

**Instructions:** Scan images for vulnerabilities.

**With Trivy:**
```bash
# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh

# Scan image
trivy image myapp:1.0

# Only critical/high
trivy image --severity HIGH,CRITICAL myapp:1.0
```

**With Grype:**
```bash
# Install Grype
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh

# Scan image
grype myapp:1.0
```

**Record any vulnerabilities found:**

_________________________________________________

_________________________________________________

---

---

## Exercise 7.4: Registry Strategy

---

**Instructions:** Design a registry strategy.

**Questions:**

1. Which registry would you use for each scenario?

   - Open source project: _________________
   - AWS deployment: _________________
   - GitHub-based team: _________________
   - Enterprise with self-hosting: _________________

2. Design a tagging strategy for your project:

   - Production releases: _________________________________________________
   - Staging builds: _________________________________________________
   - Development builds: _________________________________________________

3. What's your image promotion workflow?

   _________________________________________________
   _________________________________________________
   _________________________________________________

---

---

## Part 7 Reflection Questions

---

1. Why is image signing important? What attacks does it prevent?

_________________________________________________

_________________________________________________

_________________________________________________

2. What is an SBOM and why is it becoming required for many organizations?

_________________________________________________

_________________________________________________

_________________________________________________

3. How do vulnerability scanners like Trivy work?

_________________________________________________

_________________________________________________

_________________________________________________

4. What should your image tagging strategy include?

_________________________________________________

_________________________________________________

---

---

# PART 8: ORCHESTRATION

## Exercise 8.1: Docker Swarm

---

**Instructions:** Initialize a Swarm and deploy a service.

**Initialize Swarm:**
```bash
docker swarm init
```

**Deploy a service:**
```bash
docker service create \
  --name web \
  --replicas 3 \
  --publish published=8080,target=80 \
  nginx:alpine
```

**Check service:**
```bash
docker service ls
docker service ps web
```

**Scale the service:**
```bash
docker service scale web=5
```

**Update the service:**
```bash
docker service update --image nginx:1.25 web
```

**Rollback:**
```bash
docker service rollback web
```

**Clean up:**
```bash
docker service rm web
docker swarm leave --force
```

---

**Question:** What happens when you scale a service in Swarm?

_________________________________________________

_________________________________________________

---

---

## Exercise 8.2: Swarm Stack

---

**Instructions:** Deploy a stack with Docker Compose for Swarm.

**`docker-compose.swarm.yml`:**

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    deploy:
      replicas: 3
      update_config:
        parallelism: 2
        delay: 10s
      restart_policy:
        condition: any

  app:
    image: myapp:latest
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 256M

networks:
  webnet:
```

---

**Deploy the stack:**
```bash
docker swarm init
docker stack deploy -c docker-compose.swarm.yml myapp
docker stack services myapp
docker stack ps myapp
```

**Remove the stack:**
```bash
docker stack rm myapp
docker swarm leave --force
```

---

---

## Exercise 8.3: Kubernetes Concepts

---

**Instructions:** Map Docker concepts to Kubernetes.

**Fill in the table:**

| Docker Concept | Kubernetes Equivalent |
|----------------|----------------------|
| Container | |
| Image | |
| Volume | |
| Network | |
| docker run | |
| docker-compose.yml | |
| Port mapping | |
| Health check | |
| docker stop | |
| docker ps | |

---

**Write a simple Kubernetes Deployment:**

```yaml
# Write a deployment for a simple web app
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      # Add container specification here
```

---

---

## Part 8 Reflection Questions

---

1. When would you choose Docker Swarm over Kubernetes?

_________________________________________________

_________________________________________________

_________________________________________________

2. What is the "pets vs cattle" analogy and why is it important?

_________________________________________________

_________________________________________________

_________________________________________________

3. How does orchestration solve the problem of single-host Docker?

_________________________________________________

_________________________________________________

_________________________________________________

4. List 3 features that Kubernetes has that Swarm doesn't.

_________________________________________________

_________________________________________________

_________________________________________________

---

---

# APPENDICES

## Appendix A: Command Reference (Fill-in)

---

Complete the command examples:

**Containers:**

| Command | Purpose | Example |
|---------|---------|---------|
| docker run | Run container | ______________ |
| docker ps | List containers | ______________ |
| docker stop | ______________ | docker stop web |
| docker logs | View logs | ______________ |
| docker exec | ______________ | docker exec -it web bash |
| docker rm | Remove container | ______________ |

---

**Images:**

| Command | Purpose | Example |
|---------|---------|---------|
| docker build | ______________ | docker build -t myapp . |
| docker images | List images | ______________ |
| docker pull | Download image | ______________ |
| docker push | ______________ | docker push myrepo/myapp |
| docker rmi | Remove image | ______________ |

---

**Volumes:**

| Command | Purpose | Example |
|---------|---------|---------|
| docker volume create | ______________ | docker volume create data |
| docker volume ls | List volumes | ______________ |
| docker volume inspect | ______________ | docker volume inspect data |
| docker volume rm | Remove volume | ______________ |
| docker volume prune | ______________ | docker volume prune |

---

---

## Appendix B: Dockerfile Reference (Fill-in)

---

Complete the Dockerfile instructions:

| Instruction | Purpose | Example |
|-------------|---------|---------|
| FROM | Set base image | ______________ |
| WORKDIR | ______________ | WORKDIR /app |
| COPY | Copy files | ______________ |
| RUN | ______________ | RUN apt-get update |
| CMD | Default command | ______________ |
| ENTRYPOINT | ______________ | ENTRYPOINT ["python"] |
| ENV | Set environment | ______________ |
| EXPOSE | Document ports | ______________ |
| USER | ______________ | USER appuser |
| HEALTHCHECK | Health monitoring | ______________ |
| ARG | ______________ | ARG VERSION=latest |

---

**Write a Dockerfile for a simple Node.js app:**

_________________________________________________

_________________________________________________

_________________________________________________

_________________________________________________

_________________________________________________

---

---

## Appendix C: Docker Compose Reference (Fill-in)

---

Complete the Compose configuration:

```yaml
version: '3.8'

services:
  # Basic service
  web:
    # Use pre-built image
    ______________: nginx:alpine
    
    # Build from Dockerfile
    ______________: ./web
    
    # Port mapping
    ______________:
      - "8080:80"
    
    # Environment variables
    ______________:
      - NODE_ENV=production
    
    # Volumes
    ______________:
      - ./src:/app
    
    # Dependencies
    ______________:
      - backend
    
    # Restart policy
    ______________: unless-stopped

  backend:
    # Build with options
    ______________:
      context: ./backend
      dockerfile: Dockerfile.prod
      args:
        - VERSION=1.0
    
    # Resource limits
    ______________:
      resources:
        limits:
          memory: 512M
          cpus: '1'

# Named volumes
volumes:
  ______________:

# Networks
networks:
  ______________:
    driver: bridge
```

---

---

## Appendix D: Common Errors (Record)

---

Use this table to record errors you encounter and their solutions:

| Error Message | Cause | Solution |
|---------------|-------|----------|
| | | |
| | | |
| | | |
| | | |
| | | |
| | | |

---

---

## Appendix E: Glossary (Definitions)

---

Write definitions in your own words:

**Container:** _________________________________________________

**Image:** _________________________________________________

**Dockerfile:** _________________________________________________

**Volume:** _________________________________________________

**Bind Mount:** _________________________________________________

**Bridge Network:** _________________________________________________

**Orchestration:** _________________________________________________

**Registry:** _________________________________________________

**Multi-stage Build:** _________________________________________________

**Health Check:** _________________________________________________

---

---

# FINAL ASSESSMENT

---

## Overall Progress

Rate your confidence (1-5) after completing the series:

| Topic | Before | After |
|-------|--------|-------|
| Running containers | ___ | ___ |
| Building custom images | ___ | ___ |
| Managing volumes | ___ | ___ |
| Networking containers | ___ | ___ |
| Docker Compose | ___ | ___ |
| Production readiness | ___ | ___ |
| Debugging containers | ___ | ___ |
| Security practices | ___ | ___ |
| Registry workflows | ___ | ___ |
| Orchestration concepts | ___ | ___ |

---

## Skills Checklist

Check off skills you've mastered:

- [ ] Install Docker on my operating system
- [ ] Run containers from existing images
- [ ] Build custom images with Dockerfiles
- [ ] Write multi-stage Dockerfiles
- [ ] Use .dockerignore files
- [ ] Create and use named volumes
- [ ] Use bind mounts for development
- [ ] Create user-defined networks
- [ ] Use DNS-based service discovery
- [ ] Write docker-compose.yml files
- [ ] Use environment variables in Compose
- [ ] Add health checks to services
- [ ] Set resource limits
- [ ] Configure production logging
- [ ] Debug container issues
- [ ] Implement security hardening
- [ ] Generate SBOMs
- [ ] Sign and verify images
- [ ] Scan for vulnerabilities
- [ ] Deploy to Swarm or Kubernetes

---

## Project Ideas

What project will you build with your Docker skills?

1. _________________________________________________

2. _________________________________________________

3. _________________________________________________

---

## Next Steps

What will you learn next?

- [ ] Kubernetes certification (CKA/CKAD)
- [ ] Docker certification (DCA)
- [ ] Service mesh (Istio, Linkerd)
- [ ] GitOps (ArgoCD, Flux)
- [ ] Observability (Prometheus, Grafana)
- [ ] Cloud-native development
- [ ] Serverless containers

---

**Congratulations on completing the Docker Mastery series!**

**Your Docker journey continues...**

---

# [END OF STUDENT WORKBOOK]
