# Appendix D – Common Docker Errors and Solutions

This appendix provides a comprehensive troubleshooting guide for the most common Docker errors you'll encounter. Organized by category with clear explanations and solutions, this reference will help you quickly diagnose and fix issues.

## D.1 Container Runtime Errors

### Error: Container Exits Immediately

**Symptom:**
```bash
docker run my-image
```
```
(container exits with no output)
```

**Common Causes and Solutions:**

| Cause | Solution |
|-------|----------|
| **Command exits immediately** | The container's main process completes and exits |
| **Missing command** | Add `CMD` or `ENTRYPOINT` to Dockerfile |
| **Wrong command path** | Check that the executable exists in the container |
| **Missing dependencies** | Ensure all required packages are installed |
| **Environment variables missing** | Set required environment variables |

**Debugging:**
```bash
# Run with interactive terminal
docker run -it my-image /bin/bash

# Override command for debugging
docker run --rm -it my-image sh -c "ls -la && python app.py"

# Check last 50 logs
docker logs container-name --tail 50

# Check container exit code
docker inspect container-name --format='{{.State.ExitCode}}'
```

**Fix Example:**
```dockerfile
# BEFORE (exits immediately)
FROM python:3.11-slim
COPY app.py .
# No CMD!

# AFTER (runs properly)
FROM python:3.11-slim
COPY app.py .
CMD ["python", "app.py"]
```

### Error: Port Already Allocated

**Error Message:**
```
docker: Error response from daemon: driver failed programming external connectivity on endpoint web: Bind for 0.0.0.0:8080 failed: port is already allocated.
```

**Solutions:**

```bash
# 1. Find what's using the port
docker ps --filter "publish=8080"
lsof -i :8080  # Linux/Mac
netstat -ano | findstr :8080  # Windows

# 2. Stop the conflicting container
docker stop conflicting-container

# 3. Use a different host port
docker run -p 8081:80 my-image

# 4. Kill the process using the port
kill -9 $(lsof -t -i:8080)  # Linux/Mac
```

### Error: Container Out of Memory (OOM)

**Error Message:**
```
container_name was OOM killed
docker: Error response from daemon: OCI runtime create failed: container_linux.go:...
```

**Diagnosis:**
```bash
# Check if OOM occurred
docker inspect container-name --format='{{.State.OOMKilled}}'

# Check exit code (137 = SIGKILL, often OOM)
docker inspect container-name --format='{{.State.ExitCode}}'

# Check memory usage
docker stats container-name
```

**Solutions:**

```bash
# 1. Increase memory limit
docker run --memory=2G my-image

# 2. In Docker Compose
services:
  app:
    deploy:
      resources:
        limits:
          memory: 2G

# 3. Update existing container
docker update --memory=2G --memory-swap=4G container-name

# 4. Optimize application memory usage
# - Reduce cache sizes
# - Implement connection pooling
# - Use streaming instead of loading everything into memory
```

### Error: Permission Denied (Volume Mounts)

**Error Message:**
```
docker: Error response from daemon: error while creating mount source path '/host/path': mkdir /host/path: permission denied.
```

**Solutions:**

```bash
# 1. Check directory permissions on host
ls -la /host/path

# 2. Create directory with correct permissions
sudo mkdir -p /host/path
sudo chown $USER:$USER /host/path

# 3. Mount with read-only flag
docker run -v /host/path:/container/path:ro my-image

# 4. Use proper user mapping in Dockerfile
RUN adduser -S appuser
USER appuser

# 5. On SELinux systems (Fedora/RHEL)
docker run -v /host/path:/container/path:z my-image  # Shared label
docker run -v /host/path:/container/path:Z my-image  # Private label
```

### Error: Container Restart Loop

**Symptom:**
```bash
docker ps
```
```
CONTAINER ID   IMAGE     STATUS
abc123         myapp     Restarting (1) 2 seconds ago
```

**Diagnosis:**
```bash
# Check restart policy
docker inspect container-name --format='{{.HostConfig.RestartPolicy}}'

# Check health status
docker inspect container-name --format='{{.State.Health.Status}}'

# View health check logs
docker inspect container-name --format='{{.State.Health.Log}}'

# Check logs from multiple attempts
docker logs container-name --tail 50
```

**Solutions:**

```bash
# 1. Temporarily disable restart for debugging
docker update --restart=no container-name
docker stop container-name
docker start container-name

# 2. Check the application logs
docker logs -f container-name

# 3. Fix the underlying issue (missing config, wrong command, etc.)
# 4. Increase health check start period
# 5. Re-enable restart with proper policy
docker update --restart=always container-name
```

## D.2 Build Errors

### Error: COPY Failed - File Not Found

**Error Message:**
```
COPY failed: stat /var/lib/docker/tmp/docker-builder123456/app.py: no such file or directory
```

**Causes and Solutions:**

| Cause | Solution |
|-------|----------|
| **Wrong build context** | Use `docker build -f Dockerfile .` (note the dot) |
| **File excluded by .dockerignore** | Check `.dockerignore` file |
| **Wrong path in COPY** | Ensure path is relative to build context |
| **File doesn't exist** | Verify file exists in build context |

**Debugging:**
```bash
# Check build context contents
docker build --no-cache --progress=plain .

# List files in build context
ls -la

# Use absolute path
COPY /absolute/path /container/path  # Usually wrong
COPY ./relative/path /container/path  # Correct
```

### Error: RUN Command Failed

**Error Message:**
```
Step 5/10 : RUN apt-get update && apt-get install -y python3
 ---> Running in abc123...
E: Unable to locate package python3
The command '/bin/sh -c apt-get update && apt-get install -y python3' returned a non-zero code: 100
```

**Solutions:**

```bash
# 1. Check package name spelling
RUN apt-cache search python3

# 2. Update package cache in same RUN (not separate)
RUN apt-get update && apt-get install -y python3

# 3. Check network connectivity (proxy issues)
ENV http_proxy=http://proxy:8080
ENV https_proxy=http://proxy:8080
RUN apt-get update

# 4. Use non-interactive mode
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y --no-install-recommends python3
```

### Error: Build Cache Issues

**Symptom:** Builds take too long or use stale cache

**Solutions:**

```bash
# 1. Clear build cache
docker builder prune -a

# 2. Force rebuild without cache
docker build --no-cache -t my-image .

# 3. Use build arguments to break cache
docker build --build-arg CACHE_BUST=$(date +%s) -t my-image .

# 4. Check cache usage
docker system df -v

# 5. In Dockerfile, order layers optimally
# Least changed -> Most changed
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .  # Changes rarely
RUN pip install -r requirements.txt  # Cache hit
COPY . .  # Changes frequently
```

### Error: Dockerfile Syntax Error

**Error Message:**
```
Syntax error in Dockerfile: unknown instruction: SOME_INSTRUCTION
```

**Common Syntax Issues:**

```dockerfile
# ❌ Wrong - Uppercase only
from python:3.11

# ✅ Correct
FROM python:3.11

# ❌ Wrong - Missing space
COPY./src /app

# ✅ Correct
COPY ./src /app

# ❌ Wrong - Invalid instruction
INSTALL python3

# ✅ Correct
RUN apt-get install -y python3

# ❌ Wrong - Missing quotes for JSON array
CMD [python, app.py]

# ✅ Correct
CMD ["python", "app.py"]
```

## D.3 Network Errors

### Error: No Such Network

**Error Message:**
```
docker: Error response from daemon: network my-network not found.
```

**Solutions:**

```bash
# 1. Check existing networks
docker network ls

# 2. Create the network
docker network create my-network

# 3. In Docker Compose, define the network
services:
  app:
    networks:
      - my-network
networks:
  my-network:
    driver: bridge

# 4. Use existing network
docker run --network my-network my-image
```

### Error: DNS Resolution Failure

**Symptom:** Containers can't resolve service names

**Diagnosis:**
```bash
# Check DNS configuration
docker exec container-name cat /etc/resolv.conf

# Test DNS resolution
docker exec container-name nslookup service-name
docker exec container-name ping service-name

# Check network
docker network inspect network-name
```

**Solutions:**

```bash
# 1. Use custom DNS
docker run --dns 8.8.8.8 --dns 1.1.1.1 my-image

# 2. In Compose
services:
  app:
    dns:
      - 8.8.8.8
      - 1.1.1.1

# 3. Check if containers are on same network
docker inspect container1 --format='{{.NetworkSettings.Networks}}'
docker inspect container2 --format='{{.NetworkSettings.Networks}}'

# 4. Use container names (not IPs)
# In user-defined networks, containers can reach each other by name
```

### Error: Host Network Not Working

**Error Message:**
```
docker: Error response from daemon: Cannot start container: network host is not supported by the current user namespace.
```

**Solutions:**

```bash
# 1. Host network requires privileged access
docker run --privileged --network host my-image

# 2. On macOS/Windows, host network is limited
# Use port mapping instead: -p 8080:80

# 3. Check Docker daemon configuration
# /etc/docker/daemon.json
{
  "experimental": true,
  "features": {
    "host-network": true
  }
}
```

## D.4 Volume Errors

### Error: Volume Mount Failed

**Error Message:**
```
docker: Error response from daemon: error while mounting volume: volume driver failed...
```

**Solutions:**

```bash
# 1. Check volume exists
docker volume ls
docker volume inspect volume-name

# 2. Create volume if missing
docker volume create volume-name

# 3. Check volume driver
docker volume inspect volume-name --format='{{.Driver}}'

# 4. For NFS volumes, ensure NFS server is accessible
showmount -e nfs-server

# 5. Check permissions on mount point
ls -la /var/lib/docker/volumes/volume-name/_data
```

### Error: Volume In Use

**Error Message:**
```
Error response from daemon: remove volume-name: volume is in use - [container-id]
```

**Solutions:**

```bash
# 1. Find containers using the volume
docker ps -a --filter volume=volume-name

# 2. Stop and remove containers using the volume
docker stop container-name
docker rm container-name

# 3. Remove the volume
docker volume rm volume-name

# 4. Force removal (DANGEROUS)
docker volume rm -f volume-name
```

## D.5 Docker Daemon Errors

### Error: Cannot Connect to Docker Daemon

**Error Message:**
```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
```

**Solutions:**

**Linux:**
```bash
# Start Docker service
sudo systemctl start docker

# Enable on boot
sudo systemctl enable docker

# Check status
sudo systemctl status docker

# Start with debug
sudo dockerd --debug
```

**macOS/Windows:**
```bash
# Open Docker Desktop
# Check if it's running (menu bar icon)
# If not, start it

# Reset Docker Desktop
# Settings -> Troubleshoot -> Reset to factory defaults
```

**Permission Issues:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in, or use:
newgrp docker

# Check permissions
ls -la /var/run/docker.sock
```

### Error: No Space Left on Device

**Error Message:**
```
no space left on device
failed to register layer: write /var/lib/docker/overlay2/...: no space left on device
```

**Solutions:**

```bash
# 1. Check disk usage
df -h
docker system df

# 2. Clean up unused resources
docker system prune -a --volumes

# 3. Clean images, containers, volumes
docker container prune
docker image prune -a
docker volume prune

# 4. Remove all stopped containers
docker rm $(docker ps -a -q)

# 5. Remove all unused images
docker rmi $(docker images -q)

# 6. Move Docker storage directory (advanced)
# Edit /etc/docker/daemon.json
{
  "data-root": "/new/docker/path"
}
```

### Error: TLS Handshake Error

**Error Message:**
```
Error response from daemon: Get https://registry-1.docker.io/v2/: tls: handshake failure
```

**Solutions:**

```bash
# 1. Check proxy settings
export HTTP_PROXY=http://proxy:8080
export HTTPS_PROXY=http://proxy:8080

# 2. In Docker daemon config
# /etc/docker/daemon.json
{
  "http-proxy": "http://proxy:8080",
  "https-proxy": "http://proxy:8080",
  "no-proxy": "localhost,127.0.0.1"
}

# 3. Use HTTP registry (insecure)
docker pull --insecure-registry myregistry:5000/myimage

# 4. Trust self-signed certificates
# Add to /etc/docker/certs.d/
```

## D.6 Docker Compose Errors

### Error: Service Dependencies Not Ready

**Error Message:**
```
error while waiting for service: service never became ready
```

**Solutions:**

```yaml
# 1. Add health checks
services:
  db:
    image: postgres:15
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  app:
    depends_on:
      db:
        condition: service_healthy
```

```bash
# 2. Increase start_period
healthcheck:
  start_period: 60s

# 3. Add retries to application
import time
import sys

def wait_for_database():
    retries = 30
    while retries > 0:
        try:
            # Try connection
            return True
        except:
            time.sleep(1)
            retries -= 1
    return False

if not wait_for_database():
    sys.exit(1)
```

### Error: Compose Version Not Supported

**Error Message:**
```
version '3.8' is not supported. Use version '3.0' instead.
```

**Solutions:**

```bash
# 1. Check your Docker Compose version
docker compose version

# 2. Upgrade Docker Compose
# macOS/Windows: Update Docker Desktop
# Linux: 
sudo apt update && sudo apt install docker-compose-plugin

# 3. Use version appropriate for your Docker Engine
# Version 3.8: Docker Engine 19.03.0+
# Version 3.7: Docker Engine 18.06.0+
# Version 3.0: Docker Engine 1.13.0+

# 4. Simplify version
version: '3.0'  # More compatible
```

### Error: Env File Not Found

**Error Message:**
```
WARNING: The DB_PASSWORD variable is not set. Defaulting to a blank string.
```

**Solutions:**

```bash
# 1. Check env file exists
ls -la .env

# 2. Create .env file
cat > .env << EOF
DB_USER=appuser
DB_PASSWORD=secret
DB_NAME=appdb
EOF

# 3. Use specific env file
docker compose --env-file .env.production up

# 4. In compose file
services:
  app:
    env_file:
      - .env
      - .env.override

# 5. Set variables in shell
export DB_PASSWORD=secret
docker compose up
```

## D.7 Registry Errors

### Error: Image Not Found

**Error Message:**
```
Error response from daemon: manifest for nginx:latest not found: manifest unknown: manifest unknown
```

**Solutions:**

```bash
# 1. Check tag exists
docker search nginx  # Check available tags

# 2. Try specific version
docker pull nginx:1.25

# 3. Pull from different registry
docker pull docker.io/nginx:alpine

# 4. Check internet connection
ping docker.io
```

### Error: Authentication Required

**Error Message:**
```
denied: requested access to the resource is denied
unauthorized: authentication required
```

**Solutions:**

```bash
# 1. Login to registry
docker login
docker login ghcr.io
docker login myregistry.com

# 2. Check credentials
docker logout
docker login -u username -p password

# 3. For GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u username --password-stdin

# 4. Check token expiration
# GitHub tokens expire, create new one

# 5. Check repository permissions
# Ensure user has access to repository
```

### Error: Rate Limit Exceeded

**Error Message:**
```
Error response from daemon: toomanyrequests: You have reached your pull rate limit.
```

**Solutions:**

```bash
# 1. Use Docker Hub with authentication
docker login
docker pull nginx:alpine

# 2. Use alternative registry
docker pull ghcr.io/nginx:alpine

# 3. Set up registry mirror
# /etc/docker/daemon.json
{
  "registry-mirrors": ["https://mirror.gcr.io"]
}

# 4. Build images yourself instead of pulling
docker build -t nginx:alpine .

# 5. Use different Docker Hub account
docker login -u username2
```

## D.8 Security Errors

### Error: Running as Root

**Warning:**
```
WARNING: Running as root is not recommended. Please use a non-root user.
```

**Solutions:**

```dockerfile
# 1. In Dockerfile
FROM python:3.11-slim
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# 2. In docker run
docker run --user 1001:1001 my-image

# 3. In Docker Compose
services:
  app:
    user: "1001:1001"
```

### Error: Capability Not Permitted

**Error Message:**
```
docker: Error response from daemon: OCI runtime create failed: container_linux.go:...
```

**Solutions:**

```bash
# 1. Add required capability
docker run --cap-add=NET_ADMIN my-image

# 2. Run in privileged mode (LAST RESORT)
docker run --privileged my-image

# 3. Use host network
docker run --network host my-image

# 4. Check Docker daemon settings
# /etc/docker/daemon.json
{
  "allow-nondistributable-artifacts": false,
  "selinux-enabled": true
}
```

## D.9 Quick Troubleshooting Workflow

### The 5-Step Debugging Process

```bash
# Step 1: Check container status
docker ps -a

# Step 2: Check logs
docker logs container-name --tail 50

# Step 3: Check details
docker inspect container-name

# Step 4: Enter container (if running)
docker exec -it container-name /bin/bash

# Step 5: Check resources
docker stats container-name
docker system df
```

### Emergency Recovery Commands

```bash
# Reset everything (DANGEROUS)
docker system prune -a --volumes -f

# Stop and remove all containers
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

# Remove all images
docker rmi $(docker images -q) -f

# Reset Docker completely
# Linux:
sudo systemctl stop docker
sudo rm -rf /var/lib/docker
sudo systemctl start docker

# macOS/Windows: Reset from Docker Desktop
# Settings -> Troubleshoot -> Reset to factory defaults
```
