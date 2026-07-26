# Appendix A – Complete Docker Command Reference

This appendix serves as your quick-reference guide for all Docker commands covered throughout the series. Organized by category with practical examples, this reference will save you time when you need to recall specific commands or their flags.

## A.1 Container Management

### Running Containers

| Command | Description | Example |
|---------|-------------|---------|
| `docker run` | Create and start a container | `docker run -d --name web nginx:alpine` |
| `docker start` | Start an existing container | `docker start web` |
| `docker stop` | Stop a running container | `docker stop web` |
| `docker restart` | Restart a container | `docker restart web` |
| `docker pause` | Pause all processes in a container | `docker pause web` |
| `docker unpause` | Unpause a paused container | `docker unpause web` |
| `docker kill` | Force kill a container | `docker kill web` |
| `docker rm` | Remove a container | `docker rm web` |

### Common `docker run` Flags

```bash
# Basic flags
docker run -d                    # Run in background (detached)
docker run -it                   # Interactive terminal
docker run --rm                  # Remove container when it exits
docker run --name my-container   # Give container a name
docker run --restart always      # Restart policy

# Resource limits
docker run --cpus=1.5            # CPU cores limit
docker run --memory=512M         # Memory limit
docker run --memory-swap=1G      # Memory + swap limit

# Networking
docker run -p 8080:80            # Port mapping
docker run --network my-net      # Network to connect to
docker run --hostname my-host    # Container hostname

# Volumes
docker run -v /host:/container   # Bind mount
docker run -v my-vol:/data       # Named volume
docker run --volumes-from other  # Mount volumes from another container

# Environment
docker run -e ENV=value          # Set environment variable
docker run --env-file .env       # Load env from file

# Security
docker run --user 1001:1001      # Run as specific user
docker run --read-only           # Read-only filesystem
docker run --cap-drop ALL        # Drop all capabilities
docker run --cap-add NET_ADMIN   # Add specific capability

# Health checks
docker run --health-check-...    # Configure health check

# Logging
docker run --log-driver json-file # Set log driver
docker run --log-opt max-size=10m # Log rotation options
```

**Quick Start Examples:**
```bash
# Interactive Ubuntu shell
docker run -it --rm ubuntu:22.04 bash

# Nginx with port mapping
docker run -d --name webserver -p 8080:80 nginx:alpine

# Python app with volume and env
docker run -d --name app -v $(pwd):/app -e ENV=prod python:3.11 python app.py

# PostgreSQL with persistent volume
docker run -d --name postgres -v pgdata:/var/lib/postgresql/data -e POSTGRES_PASSWORD=secret postgres:15
```

### Container Inspection

| Command | Description | Example |
|---------|-------------|---------|
| `docker ps` | List running containers | `docker ps -a` |
| `docker inspect` | Show detailed container info | `docker inspect web` |
| `docker logs` | Show container logs | `docker logs -f web` |
| `docker top` | Show running processes in container | `docker top web` |
| `docker stats` | Show resource usage (live) | `docker stats web` |
| `docker events` | Monitor Docker events | `docker events --filter container=web` |
| `docker diff` | Show changes to container filesystem | `docker diff web` |
| `docker port` | Show port mappings | `docker port web` |

**Useful `docker ps` Formats:**
```bash
# Show all containers with human-readable sizes
docker ps -as

# Custom format table
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"

# Show only container IDs
docker ps -q

# Filter by status
docker ps --filter "status=exited"
docker ps --filter "status=running"
docker ps --filter "label=environment=prod"
```

**Advanced `docker inspect` Queries:**
```bash
# Get IP address
docker inspect web --format='{{.NetworkSettings.IPAddress}}'

# Get container status
docker inspect web --format='{{.State.Status}}'

# Get environment variables
docker inspect web --format='{{.Config.Env}}'

# Get mounted volumes
docker inspect web --format='{{json .Mounts}}' | jq '.'

# Check if container is healthy
docker inspect web --format='{{.State.Health.Status}}'

# Get complete JSON with pretty print
docker inspect web | jq '.'

# Get network settings
docker inspect web --format='{{json .NetworkSettings}}' | jq '.'
```

### Container Interaction

| Command | Description | Example |
|---------|-------------|---------|
| `docker exec` | Run command in running container | `docker exec -it web bash` |
| `docker cp` | Copy files to/from container | `docker cp ./file web:/app/` |
| `docker attach` | Attach to running container | `docker attach web` |
| `docker wait` | Wait for container to exit | `docker wait web` |

**Copy Examples:**
```bash
# Copy from container to host
docker cp web:/app/logs/app.log ./app.log

# Copy from host to container
docker cp ./config.json web:/app/config.json

# Copy directory from container
docker cp web:/app/data ./data-backup

# Copy with permissions preserved
docker cp -a web:/app/static ./static
```

## A.2 Image Management

### Building Images

| Command | Description | Example |
|---------|-------------|---------|
| `docker build` | Build image from Dockerfile | `docker build -t my-app .` |
| `docker buildx` | Build with BuildKit | `docker buildx build --platform linux/amd64` |

**Common `docker build` Flags:**
```bash
docker build -t my-app:1.0      # Tag the image
docker build --no-cache         # Ignore build cache
docker build --pull             # Always pull base images
docker build --build-arg VERSION=1.0  # Pass build arguments
docker build --file Dockerfile.prod   # Use specific Dockerfile
docker build --progress=plain   # Show full output

# BuildKit enhancements
export DOCKER_BUILDKIT=1
docker build --cache-from my-app:cache  # Use specific cache image
docker build --ssh default      # Forward SSH agent
docker build --secret id=mysecret,src=./secret.txt  # Mount secrets
```

### Managing Images

| Command | Description | Example |
|---------|-------------|---------|
| `docker images` | List images | `docker images` |
| `docker pull` | Pull image from registry | `docker pull nginx:alpine` |
| `docker push` | Push image to registry | `docker push myrepo/app:1.0` |
| `docker rmi` | Remove image | `docker rmi my-app:1.0` |
| `docker tag` | Tag an image | `docker tag app:latest myrepo/app:v1` |
| `docker history` | Show image history | `docker history nginx:alpine` |
| `docker save` | Export image to tar | `docker save -o app.tar my-app` |
| `docker load` | Load image from tar | `docker load -i app.tar` |
| `docker export` | Export container to tar | `docker export web > web.tar` |
| `docker import` | Import from tar | `docker import web.tar my-app:new` |

**Image Cleanup:**
```bash
# Remove unused images
docker image prune

# Remove all unused images (aggressive)
docker image prune -a

# Remove dangling images
docker rmi $(docker images -f "dangling=true" -q)

# Remove images older than 24 hours
docker images --filter "until=24h" -q | xargs docker rmi

# Remove all images
docker rmi $(docker images -q)
```

### Registry Operations

```bash
# Login to registry
docker login docker.io
docker login ghcr.io
docker login myregistry.com

# Tag for registry
docker tag my-app:1.0 docker.io/username/app:1.0

# Push to registry
docker push docker.io/username/app:1.0

# Pull from registry
docker pull docker.io/username/app:1.0

# Search registry
docker search nginx

# Logout
docker logout
```

## A.3 Network Management

### Network Commands

| Command | Description | Example |
|---------|-------------|---------|
| `docker network ls` | List networks | `docker network ls` |
| `docker network create` | Create a network | `docker network create my-net` |
| `docker network inspect` | Show network details | `docker network inspect my-net` |
| `docker network connect` | Connect container to network | `docker network connect my-net web` |
| `docker network disconnect` | Disconnect container from network | `docker network disconnect my-net web` |
| `docker network prune` | Remove unused networks | `docker network prune` |
| `docker network rm` | Remove a network | `docker network rm my-net` |

### Network Drivers

```bash
# Bridge (default)
docker network create --driver bridge my-bridge

# Host (uses host networking)
docker network create --driver host host-net

# None (no networking)
docker network create --driver none isolated

# Overlay (for Swarm/Kubernetes)
docker network create --driver overlay --attachable overlay-net

# Macvlan (assign MAC addresses)
docker network create --driver macvlan --subnet=192.168.1.0/24 --gateway=192.168.1.1 -o parent=eth0 macvlan-net
```

### Advanced Network Configuration

```bash
# Create network with custom subnet
docker network create \
  --subnet=172.20.0.0/16 \
  --gateway=172.20.0.1 \
  custom-network

# Connect container with specific IP
docker run --network custom-network --ip 172.20.0.50 nginx

# Create network with network alias
docker run --network custom-network --network-alias api nginx

# Create network with IPv6
docker network create \
  --ipv6 \
  --subnet=2001:db8:1::/64 \
  ipv6-network

# External network
docker network create --external external-net
```

## A.4 Volume Management

### Volume Commands

| Command | Description | Example |
|---------|-------------|---------|
| `docker volume ls` | List volumes | `docker volume ls` |
| `docker volume create` | Create a volume | `docker volume create my-vol` |
| `docker volume inspect` | Show volume details | `docker volume inspect my-vol` |
| `docker volume rm` | Remove a volume | `docker volume rm my-vol` |
| `docker volume prune` | Remove unused volumes | `docker volume prune` |

### Volume Drivers

```bash
# Local driver (default)
docker volume create --driver local my-vol

# NFS driver
docker volume create \
  --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.100,rw \
  --opt device=:/exported/path \
  nfs-volume

# S3 driver (needs plugin)
docker volume create \
  --driver s3 \
  --opt endpoint=http://minio:9000 \
  --opt bucket=my-bucket \
  s3-volume

# Local with specific mount options
docker volume create \
  --driver local \
  --opt type=tmpfs \
  --opt device=tmpfs \
  --opt o=size=100m,uid=1000 \
  tmpfs-volume
```

### Data Operations

```bash
# Backup a volume
docker run --rm \
  -v my-vol:/source \
  -v $(pwd):/backup \
  alpine tar czf /backup/backup.tar.gz -C /source .

# Restore a volume
docker run --rm \
  -v my-vol:/target \
  -v $(pwd):/backup \
  alpine tar xzf /backup/backup.tar.gz -C /target

# Copy data between volumes
docker run --rm \
  -v source-vol:/from \
  -v target-vol:/to \
  alpine cp -a /from/. /to/

# Inspect volume usage
docker run --rm -v my-vol:/data alpine du -sh /data
```

## A.5 Docker Compose Commands

### Core Commands

| Command | Description | Example |
|---------|-------------|---------|
| `docker compose up` | Start services | `docker compose up -d` |
| `docker compose down` | Stop and remove | `docker compose down -v` |
| `docker compose ps` | List services | `docker compose ps` |
| `docker compose logs` | View logs | `docker compose logs -f backend` |
| `docker compose exec` | Run command in service | `docker compose exec web bash` |
| `docker compose run` | Run one-off command | `docker compose run --rm web npm install` |
| `docker compose build` | Build or rebuild services | `docker compose build --no-cache` |
| `docker compose push` | Push service images | `docker compose push` |
| `docker compose pull` | Pull service images | `docker compose pull` |
| `docker compose start` | Start services | `docker compose start` |
| `docker compose stop` | Stop services | `docker compose stop` |
| `docker compose restart` | Restart services | `docker compose restart web` |
| `docker compose pause` | Pause services | `docker compose pause` |
| `docker compose unpause` | Unpause services | `docker compose unpause` |
| `docker compose rm` | Remove stopped containers | `docker compose rm -f` |
| `docker compose scale` | Scale services | `docker compose scale web=3` |
| `docker compose config` | Validate and view config | `docker compose config` |
| `docker compose events` | Monitor events | `docker compose events` |
| `docker compose port` | Show mapped ports | `docker compose port web 80` |

### Useful Flags

```bash
# Up with specific compose file
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Up with specific project name
docker compose -p myproject up -d

# Up with specific profile
docker compose --profile dev-tools up -d

# Up without building
docker compose up --no-build

# Up with no color output
docker compose up --no-color

# Up with attached to specific service
docker compose up web

# Down with removal of volumes
docker compose down -v --rmi local

# Down with removal of images
docker compose down --rmi all

# Exec with environment variables
docker compose exec -e ENV=prod web node app.js
```

### Configuration Commands

```bash
# Validate compose file
docker compose config

# Validate and show full config
docker compose config --resolve-image-digests

# Show with default values
docker compose config --defaults

# Show only services names
docker compose config --services

# Show with variables substituted
docker compose config --variables
```

## A.6 Swarm Commands

| Command | Description | Example |
|---------|-------------|---------|
| `docker swarm init` | Initialize swarm | `docker swarm init --advertise-addr 192.168.1.100` |
| `docker swarm join` | Join swarm | `docker swarm join --token SWMTKN-... 192.168.1.100:2377` |
| `docker swarm leave` | Leave swarm | `docker swarm leave --force` |
| `docker swarm update` | Update swarm | `docker swarm update --autolock` |
| `docker node ls` | List nodes | `docker node ls` |
| `docker node inspect` | Inspect node | `docker node inspect node1` |
| `docker node update` | Update node | `docker node update --availability drain node1` |
| `docker node promote` | Promote to manager | `docker node promote node2` |
| `docker node demote` | Demote to worker | `docker node demote node2` |
| `docker service create` | Create service | `docker service create --name web --replicas 3 nginx` |
| `docker service ls` | List services | `docker service ls` |
| `docker service inspect` | Inspect service | `docker service inspect web` |
| `docker service ps` | List service tasks | `docker service ps web` |
| `docker service scale` | Scale service | `docker service scale web=5` |
| `docker service update` | Update service | `docker service update --image nginx:1.25 web` |
| `docker service rollback` | Rollback service | `docker service rollback web` |
| `docker service rm` | Remove service | `docker service rm web` |
| `docker stack deploy` | Deploy stack | `docker stack deploy -c compose.yml myapp` |
| `docker stack ls` | List stacks | `docker stack ls` |
| `docker stack ps` | List stack tasks | `docker stack ps myapp` |
| `docker stack services` | List stack services | `docker stack services myapp` |
| `docker stack rm` | Remove stack | `docker stack rm myapp` |
| `docker stack config` | View stack config | `docker stack config` |

## A.7 Docker System Management

### System Commands

| Command | Description | Example |
|---------|-------------|---------|
| `docker system df` | Show disk usage | `docker system df -v` |
| `docker system prune` | Remove unused data | `docker system prune -a --volumes` |
| `docker system info` | Show system info | `docker system info` |
| `docker system events` | Show system events | `docker system events` |
| `docker version` | Show Docker version | `docker version` |
| `docker info` | Show system info | `docker info` |

### Cleanup Commands

```bash
# Remove all unused containers, networks, images, build cache
docker system prune

# Include all unused images
docker system prune -a

# Include volumes
docker system prune --volumes

# Force without prompt
docker system prune -f

# Show space reclaimed
docker system prune -a --volumes --filter "until=24h"

# Remove all stopped containers
docker container prune

# Remove all unused images
docker image prune -a

# Remove all unused networks
docker network prune

# Remove all unused volumes
docker volume prune

# Remove all build cache
docker builder prune -a
```

## A.8 Context and Configuration

### Context Management

```bash
# List contexts
docker context ls

# Create new context
docker context create mycontext --docker "host=ssh://user@server"

# Use specific context
docker context use mycontext

# Inspect context
docker context inspect mycontext

# Remove context
docker context rm mycontext
```

### BuildX Configuration

```bash
# Create new buildx builder
docker buildx create --name mybuilder

# Use specific builder
docker buildx use mybuilder

# Inspect builder
docker buildx inspect --bootstrap

# Build multi-platform
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t myapp:latest \
  --push .

# List builders
docker buildx ls

# Remove builder
docker buildx rm mybuilder
```

## A.9 Quick Troubleshooting Reference

### Common Errors and Solutions

| Error | Possible Cause | Solution |
|-------|---------------|----------|
| `port is already allocated` | Port in use | Change host port or stop conflicting container |
| `No such container` | Container doesn't exist | Check name with `docker ps -a` |
| `Cannot connect to Docker daemon` | Docker not running | Start Docker service |
| `Permission denied` | User not in docker group | `sudo usermod -aG docker $USER` |
| `Image not found` | Image doesn't exist | Pull image with `docker pull` |
| `Executable not found` | Wrong path/command | Check `CMD` in Dockerfile |
| `Memory limit too low` | OOM Killer | Increase memory limits |
| `No such image` | Image not built | Build image with `docker build` |
| `Network not found` | Network doesn't exist | Create network first |
| `Volume not found` | Volume doesn't exist | Create volume or use named volume |

### Debugging Commands Cheat Sheet

```bash
# Quick health check
docker ps && docker compose ps

# Check container logs
docker logs --tail 50 $CONTAINER

# Enter container
docker exec -it $CONTAINER /bin/bash

# Check resource usage
docker stats --no-stream $CONTAINER

# Check detailed info
docker inspect $CONTAINER

# Check network connectivity
docker exec $CONTAINER ping $SERVICE

# Check DNS resolution
docker exec $CONTAINER nslookup $SERVICE

# Check open ports
docker exec $CONTAINER netstat -tulpn

# Check environment variables
docker exec $CONTAINER env

# Check disk usage
docker exec $CONTAINER df -h

# Check process list
docker exec $CONTAINER ps aux

# Copy logs out
docker cp $CONTAINER:/app/logs/app.log ./app.log

# Check volume permissions
docker run --rm -v $VOLUME:/data alpine ls -la /data

# Monitor Docker events
docker events --filter container=$CONTAINER
```
[STARTING: Appendix B – Dockerfile Reference]
