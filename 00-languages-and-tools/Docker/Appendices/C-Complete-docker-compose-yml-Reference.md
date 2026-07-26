# Appendix C – Complete docker-compose.yml Reference

This appendix provides a comprehensive reference for Docker Compose configuration. Use this as your definitive guide when defining multi-container applications with Docker Compose.

## C.1 Compose File Structure

```yaml
version: '3.8'           # Compose file format version

services:                # Define your services/containers
  service1:
    # ... configuration ...
  service2:
    # ... configuration ...

volumes:                 # Define named volumes
  volume1:
    # ... configuration ...
  volume2:
    # ... configuration ...

networks:                # Define custom networks
  network1:
    # ... configuration ...
  network2:
    # ... configuration ...

configs:                 # Define configs (Swarm mode)
  config1:
    # ... configuration ...

secrets:                 # Define secrets (Swarm mode)
  secret1:
    # ... configuration ...
```

## C.2 Version Compatibility Matrix

| Version | Docker Engine | Features |
|---------|---------------|----------|
| 3.8     | 19.03.0+      | Latest features, OCI support |
| 3.7     | 18.06.0+      | Init containers, service configs |
| 3.6     | 18.02.0+      | Swarm: placement preferences, tmpfs |
| 3.5     | 17.12.0+      | Configs in Swarm, ISCSI volumes |
| 3.4     | 17.09.0+      | Swarm: secrets, service update options |
| 3.3     | 17.06.0+      | Docker Stack: configs in Swarm |
| 3.2     | 17.04.0+      | Docker Stack: healthchecks, nested volumes |
| 3.1     | 1.13.1+       | Docker Stack: new features |
| 3.0     | 1.13.0+       | Docker Stack support, Docker for Swarm |

## C.3 Service Configuration Reference

### Core Service Options

```yaml
services:
  app:
    # ============================================================
    # Image & Build
    # ============================================================
    image: nginx:alpine                    # Use pre-built image
    build: ./backend                        # Build from Dockerfile in path
    build:
      context: ./backend                   # Build context path
      dockerfile: Dockerfile.prod          # Specific Dockerfile
      args:                                # Build arguments
        - NODE_ENV=production
        - VERSION=1.0.0
      target: builder                      # Specific build stage
      labels:                              # Labels for the built image
        - "build.version=1.0.0"
      cache_from:                          # Cache images to use
        - nginx:alpine
        - myapp:cache
      extra_hosts:                         # Hosts to add during build
        - "host.docker.internal:host-gateway"
      isolation: default                   # Isolation level (Windows)
      
    # ============================================================
    # Container Identification
    # ============================================================
    container_name: my-app                  # Custom container name
    hostname: my-host                      # Container hostname
    domainname: example.com                # Container domain name
    labels:                                # Container labels
      - "com.example.environment=production"
      - "com.example.version=1.0.0"
    
    # ============================================================
    # Ports & Networking
    # ============================================================
    ports:                                 # Port mapping
      - "8080:80"                          # Host:Container
      - "8443:443/tcp"                     # With protocol
      - "53:53/udp"                        # UDP port
      - target: 80                         # Extended syntax
        published: 8080
        protocol: tcp
        mode: host                         # host or ingress
    
    expose:                                # Expose ports internally
      - "3000"
      - "8000/tcp"
    
    networks:                              # Networks to connect to
      - frontend
      - backend
      
    network_mode: bridge                   # Network mode (bridge, host, none)
    
    dns:                                   # DNS servers
      - 8.8.8.8
      - 1.1.1.1
      
    dns_search:                            # DNS search domains
      - example.com
      - internal.example.com
    
    extra_hosts:                           # Host entries
      - "host.docker.internal:host-gateway"
      - "database:192.168.1.100"
    
    # ============================================================
    # Volumes & Storage
    # ============================================================
    volumes:                               # Volume mounts
      - postgres-data:/var/lib/postgresql/data  # Named volume
      - ./app-data:/app/data                     # Bind mount
      - ./config:/app/config:ro                  # Read-only bind mount
      - type: volume                       # Extended syntax
        source: myvolume
        target: /data
        read_only: true
      - type: bind
        source: ./logs
        target: /app/logs
        bind:
          propagation: rshared
      - type: tmpfs                         # tmpfs mount
        target: /tmp
        tmpfs:
          size: 100M
          mode: 0700
          uid: 1001
          gid: 1001
    
    tmpfs:                                 # Simplified tmpfs (legacy)
      - /tmp:size=100M
      - /run:uid=1001,gid=1001
    
    volumes_from:                          # Mount from other container
      - data-container:ro
    
    # ============================================================
    # Environment Variables
    # ============================================================
    environment:                           # Direct key-value
      - NODE_ENV=production
      - DB_HOST=postgres
      - DB_PORT=5432
      - SECRET_KEY=${SECRET_KEY}          # From shell/environment
      - LOG_LEVEL: info
      
    env_file:                              # Load from file(s)
      - .env                              # Single file
      - .env.production                   # Multiple files (override)
      - ./configs/env/app.env
    
    # ============================================================
    # Command & Entrypoint
    # ============================================================
    command: ["python", "app.py", "--port", "5000"]  # Override CMD
    command: python app.py --port 5000     # Shell form
    
    entrypoint: ["python"]                 # Override ENTRYPOINT
    entrypoint: /bin/sh -c "python"        # Shell form
    
    # ============================================================
    # Dependencies
    # ============================================================
    depends_on:                            # Service dependencies
      - postgres                           # Wait for start
      - redis
      
    depends_on:                            # With conditions (v3.8+)
      postgres:
        condition: service_healthy         # Wait for healthy
      redis:
        condition: service_started         # Wait for start
      backend:
        condition: service_completed_successfully
    
    # ============================================================
    # Resources & Limits
    # ============================================================
    deploy:                                # Deployment resources (Swarm/K8s)
      resources:
        limits:
          cpus: '1.5'
          memory: 512M
          pids: 100
        reservations:
          cpus: '0.5'
          memory: 256M
        limits:
          cpus: '2'
          memory: 1G
      
      restart_policy:
        condition: any                    # any, on-failure, unless-stopped
        delay: 5s
        max_attempts: 3
        window: 120s
      
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
        order: start-first                # start-first or stop-first
        monitor: 60s
        max_failure_ratio: 0.3
      
      rollback_config:
        parallelism: 1
        delay: 10s
        failure_action: pause
        order: start-first
        monitor: 60s
      
      placement:
        constraints:
          - node.role == worker
          - node.labels.region == us-east
        preferences:
          - spread: node.labels.datacenter
    
    ulimits:                               # Resource limits
      nofile:
        soft: 65536
        hard: 65536
      nproc:
        soft: 512
        hard: 512
    
    mem_limit: 512M                        # Legacy (use deploy.resources)
    memswap_limit: 1G
    cpu_shares: 512                        # CPU weight (relative)
    cpus: '1'                              # CPU limit (legacy)
    
    # ============================================================
    # Security
    # ============================================================
    user: "1001:1001"                      # Run as specific user
    user: appuser:appgroup                 # By name
    
    read_only: true                        # Read-only filesystem
    
    cap_add:                               # Add capabilities
      - NET_BIND_SERVICE
      - CHOWN
      - DAC_OVERRIDE
    
    cap_drop:                              # Drop capabilities
      - ALL
    
    security_opt:                          # Security options
      - no-new-privileges:true
      - apparmor:profile-name
      - seccomp:unconfined
      - label:user:USER
    
    privileged: false                      # Privileged mode
    pid: host                              # PID namespace
    
    # ============================================================
    # Health Checks
    # ============================================================
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s
    
    # ============================================================
    # Logging
    # ============================================================
    logging:
      driver: "json-file"                  # json-file, syslog, fluentd, etc.
      options:
        max-size: "10m"
        max-file: "3"
        tag: "{{.Name}}/{{.ID}}"
        labels: "production"
    
    log_driver: "syslog"                   # Legacy
    log_opt:
      syslog-address: "tcp://192.168.0.42:123"
    
    # ============================================================
    # Restart Policy
    # ============================================================
    restart: unless-stopped                # no, always, on-failure, unless-stopped
    
    # ============================================================
    # Other Options
    # ============================================================
    sysctls:                               # Kernel parameters
      - net.core.somaxconn=1024
      - net.ipv4.tcp_syncookies=0
    
    shm_size: 256mb                        # Shared memory size
    
    stop_signal: SIGTERM                   # Stop signal
    stop_grace_period: 30s                 # Grace period for shutdown
    
    init: true                             # Use init process for zombie reaping
    
    profiles:                              # Profiles for selective startup
      - production
      - debug
    
    scale: 3                               # Number of replicas (legacy)
    
    group_add:                             # Additional groups
      - 1001
      - appgroup
```

## C.4 Volume Configuration Reference

### Basic Volume Definition

```yaml
volumes:
  # Basic named volume
  postgres-data:
  
  # With driver and options
  redis-data:
    driver: local
    driver_opts:
      type: none
      device: /var/lib/docker/volumes/redis
      o: bind
  
  # External volume (created outside compose)
  external-volume:
    external: true
    external:
      name: my-existing-volume
  
  # Volume with labels
  app-data:
    labels:
      - "com.example.environment=production"
      - "com.example.backup=true"
  
  # Volume with specific driver
  cloud-volume:
    driver: amazon-ebs
    driver_opts:
      size: 100
      type: gp2
      region: us-east-1
```

### Volume Example for Different Storage Types

```yaml
volumes:
  # Basic volume for database persistence
  db-data:
    driver: local
    driver_opts:
      type: none
      device: ${DATA_PATH:-./data}/postgres
      o: bind
  
  # NFS volume for shared storage
  shared-storage:
    driver: local
    driver_opts:
      type: nfs
      o: addr=192.168.1.100,rw,noatime
      device: ":/exported/path"
  
  # Tempfs volume for cache
  cache-data:
    driver: local
    driver_opts:
      type: tmpfs
      device: tmpfs
      o: size=100M,uid=1000,gid=1000
  
  # Encrypted volume (using plugin)
  encrypted-storage:
    driver: encryption-plugin
    driver_opts:
      key: ${ENCRYPTION_KEY}
  
  # Read-only config volume
  config-volume:
    driver: local
    driver_opts:
      type: none
      device: ./configs
      o: bind,ro
```

## C.5 Network Configuration Reference

### Network Definitions

```yaml
networks:
  # Basic bridge network
  frontend:
    driver: bridge
  
  # Network with custom subnet
  backend:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/16
          gateway: 172.20.0.1
        - subnet: 2001:db8:1::/64
          gateway: 2001:db8:1::1
  
  # External network
  external-net:
    external: true
    external:
      name: pre-existing-network
  
  # Overlay network (Swarm)
  overlay-net:
    driver: overlay
    attachable: true
    ipam:
      config:
        - subnet: 10.0.0.0/24
  
  # Macvlan network
  macvlan-net:
    driver: macvlan
    driver_opts:
      parent: eth0
    ipam:
      config:
        - subnet: 192.168.1.0/24
          gateway: 192.168.1.1
  
  # Network with labels
  monitoring:
    driver: bridge
    labels:
      - "com.example.environment=production"
      - "com.example.monitoring=true"
  
  # IPv6 network
  ipv6-net:
    driver: bridge
    enable_ipv6: true
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/16
          gateway: 172.20.0.1
        - subnet: 2001:db8:1::/64
          gateway: 2001:db8:1::1
```

### Network Assignment in Services

```yaml
services:
  web:
    networks:
      - frontend
      - backend
      - monitoring
    
  app:
    networks:
      frontend:
        # Static IP (on specific network)
        ipv4_address: 172.20.0.50
        aliases:
          - webapp
          - api
      backend:
        priority: 10
    
  db:
    networks:
      backend:
        ipv4_address: 172.20.0.100
      monitoring:
```

### Multi-Network Access Control

```yaml
# Frontend network (public accessible)
networks:
  public:
    driver: bridge
    internal: false  # Can access the internet
  
  private:
    driver: bridge
    internal: true   # No internet access
  
  database:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.21.0.0/16

services:
  web:
    networks:
      - public
      - private
    # Can access internet (public) and internal services (private)
  
  app:
    networks:
      - private
      - database
    # No internet access, can talk to database
  
  db:
    networks:
      - database
    # Only accessible via database network
```

## C.6 Configs and Secrets (Swarm Mode)

### Configs Definition

```yaml
configs:
  # File-based config
  app-config:
    file: ./configs/app.conf
  
  # External config
  external-config:
    external: true
    external:
      name: my-external-config
  
  # Config with custom name
  nginx-config:
    file: ./nginx/nginx.conf
    name: web_nginx_config

services:
  web:
    configs:
      - source: app-config
        target: /etc/app/config.conf
        uid: '1001'
        gid: '1001'
        mode: 0440
      - source: nginx-config
        target: /etc/nginx/conf.d/default.conf
```

### Secrets Definition

```yaml
secrets:
  # File-based secret
  db_password:
    file: ./secrets/db_password.txt
  
  # External secret
  api_key:
    external: true
    external:
      name: my-api-key
  
  # Secret with custom name
  ssl-cert:
    file: ./secrets/ssl.cert
    name: web_ssl_cert

services:
  app:
    secrets:
      - db_password
      - source: api_key
        target: /run/secrets/api_key
        uid: '1001'
        gid: '1001'
        mode: 0400
```

## C.7 Complete Compose Examples

### Example 1: Web Application Stack

```yaml
version: '3.8'

services:
  # ============================================================
  # Nginx Reverse Proxy
  # ============================================================
  nginx:
    image: nginx:alpine
    container_name: web-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
      - ./certbot/www:/var/www/certbot:ro
    networks:
      - web
    depends_on:
      - frontend
      - backend
    restart: unless-stopped
    logging:
      driver: json-file
      options:
        max-size: 10m
        max-file: 3

  # ============================================================
  # Frontend (React/Vue)
  # ============================================================
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
      target: production
    container_name: web-frontend
    environment:
      - NODE_ENV=production
      - API_URL=http://backend:5000
    networks:
      - web
      - backend
    depends_on:
      - backend
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
        reservations:
          cpus: '0.25'
          memory: 128M

  # ============================================================
  # Backend API (Node.js/Python)
  # ============================================================
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: web-backend
    environment:
      - NODE_ENV=production
      - DB_HOST=postgres
      - DB_USER=${DB_USER}
      - DB_PASSWORD=${DB_PASSWORD}
      - DB_NAME=${DB_NAME}
      - REDIS_HOST=redis
      - SECRET_KEY=${SECRET_KEY}
    volumes:
      - ./backend/logs:/app/logs
      - ./backend/uploads:/app/uploads
    networks:
      - backend
      - database
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped
    read_only: true
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 40s

  # ============================================================
  # PostgreSQL Database
  # ============================================================
  postgres:
    image: postgres:15-alpine
    container_name: web-postgres
    environment:
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=${DB_NAME}
      - PGDATA=/var/lib/postgresql/data/pgdata
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./postgres/init:/docker-entrypoint-initdb.d:ro
    networks:
      - database
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
    shm_size: 256mb
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

  # ============================================================
  # Redis Cache
  # ============================================================
  redis:
    image: redis:7.2-alpine
    container_name: web-redis
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru
    volumes:
      - redis-data:/data
    networks:
      - database
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 128M
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5

  # ============================================================
  # Worker (Background Jobs)
  # ============================================================
  worker:
    build:
      context: ./backend
      dockerfile: Dockerfile.worker
    container_name: web-worker
    environment:
      - DB_HOST=postgres
      - DB_USER=${DB_USER}
      - DB_PASSWORD=${DB_PASSWORD}
      - DB_NAME=${DB_NAME}
      - REDIS_HOST=redis
    networks:
      - database
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
        reservations:
          cpus: '0.25'
          memory: 128M

# ============================================================
# Volumes
# ============================================================
volumes:
  postgres-data:
    driver: local
    driver_opts:
      type: none
      device: ${DATA_PATH:-./data}/postgres
      o: bind
  redis-data:
    driver: local
    driver_opts:
      type: none
      device: ${DATA_PATH:-./data}/redis
      o: bind

# ============================================================
# Networks
# ============================================================
networks:
  web:
    driver: bridge
    name: web-network
  backend:
    driver: bridge
    name: backend-network
    internal: true
  database:
    driver: bridge
    name: database-network
    internal: true
```

### Example 2: Development Environment

```yaml
version: '3.8'

# Development specific configuration
services:
  # ============================================================
  # Backend (with hot reload)
  # ============================================================
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    container_name: dev-backend
    environment:
      - NODE_ENV=development
      - DB_HOST=postgres
      - DB_USER=devuser
      - DB_PASSWORD=devpass
      - DB_NAME=devdb
      - REDIS_HOST=redis
      - LOG_LEVEL=debug
    volumes:
      - ./backend:/app:rw
      - /app/node_modules  # Anonymous volume for node_modules
    ports:
      - "5000:5000"
      - "9229:9229"        # Node debug port
    networks:
      - dev
    depends_on:
      - postgres
      - redis
    command: npm run dev  # Hot reload enabled

  # ============================================================
  # Frontend (with hot reload)
  # ============================================================
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    container_name: dev-frontend
    environment:
      - NODE_ENV=development
    volumes:
      - ./frontend:/app:rw
      - /app/node_modules
    ports:
      - "3000:3000"
      - "9229:9229"        # Node debug port
    networks:
      - dev
    command: npm start

  # ============================================================
  # Database (dev)
  # ============================================================
  postgres:
    image: postgres:15-alpine
    container_name: dev-postgres
    environment:
      - POSTGRES_USER=devuser
      - POSTGRES_PASSWORD=devpass
      - POSTGRES_DB=devdb
    ports:
      - "5432:5432"        # Expose to host for local tools
    volumes:
      - postgres-dev:/var/lib/postgresql/data
      - ./postgres/init:/docker-entrypoint-initdb.d:ro
    networks:
      - dev

  # ============================================================
  # Redis (dev)
  # ============================================================
  redis:
    image: redis:7.2-alpine
    container_name: dev-redis
    ports:
      - "6379:6379"        # Expose to host for local tools
    volumes:
      - redis-dev:/data
    networks:
      - dev

  # ============================================================
  # Database Admin UI (dev tools)
  # ============================================================
  adminer:
    image: adminer:latest
    container_name: dev-adminer
    ports:
      - "8081:8080"
    networks:
      - dev
    profiles:
      - dev-tools

  # ============================================================
  # MailCatcher (dev)
  # ============================================================
  mailcatcher:
    image: schickling/mailcatcher:latest
    container_name: dev-mailcatcher
    ports:
      - "1080:1080"
      - "1025:1025"
    networks:
      - dev
    profiles:
      - dev-tools

# ============================================================
# Volumes
# ============================================================
volumes:
  postgres-dev:
  redis-dev:

# ============================================================
# Networks
# ============================================================
networks:
  dev:
    driver: bridge
    name: dev-network
```

### Example 3: Testing Environment

```yaml
version: '3.8'

services:
  # ============================================================
  # Test Runner
  # ============================================================
  test:
    build:
      context: ./backend
      dockerfile: Dockerfile.test
    container_name: test-runner
    environment:
      - NODE_ENV=test
      - DB_HOST=postgres-test
      - DB_USER=testuser
      - DB_PASSWORD=testpass
      - DB_NAME=testdb
      - REDIS_HOST=redis-test
    volumes:
      - ./backend:/app:ro
      - ./coverage:/app/coverage
    networks:
      - test
    depends_on:
      postgres-test:
        condition: service_healthy
      redis-test:
        condition: service_healthy
    command: npm test -- --coverage

  # ============================================================
  # Test Database
  # ============================================================
  postgres-test:
    image: postgres:15-alpine
    container_name: test-postgres
    environment:
      - POSTGRES_USER=testuser
      - POSTGRES_PASSWORD=testpass
      - POSTGRES_DB=testdb
    networks:
      - test
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U testuser -d testdb"]
      interval: 5s
      timeout: 3s
      retries: 5

  # ============================================================
  # Test Redis
  # ============================================================
  redis-test:
    image: redis:7.2-alpine
    container_name: test-redis
    networks:
      - test

networks:
  test:
    driver: bridge
```

## C.8 Common Compose File Patterns

### Pattern 1: Environment-Specific Overrides

```yaml
# docker-compose.yml (base)
version: '3.8'

services:
  app:
    image: myapp:latest
    environment:
      - NODE_ENV=production
    ports:
      - "8080:80"
```

```yaml
# docker-compose.override.yml (development)
version: '3.8'

services:
  app:
    environment:
      - NODE_ENV=development
    volumes:
      - ./src:/app/src
    command: npm run dev
```

```yaml
# docker-compose.prod.yml (production)
version: '3.8'

services:
  app:
    environment:
      - NODE_ENV=production
      - LOG_LEVEL=info
    restart: always
    deploy:
      replicas: 3
```

### Pattern 2: Service Profiles

```yaml
version: '3.8'

services:
  app:
    build: .
    profiles:
      - production
      - development
    # ...

  monitoring:
    image: prom/prometheus
    profiles:
      - monitoring
      - development
    # ...

  debug:
    image: alpine
    command: sleep infinity
    profiles:
      - debug
    # ...
```

### Pattern 3: Extension Fields

```yaml
version: '3.8'

# Define reusable configurations
x-logging: &default-logging
  driver: json-file
  options:
    max-size: 10m
    max-file: 3

x-health: &health-default
  interval: 30s
  timeout: 5s
  retries: 3
  start_period: 10s

services:
  app:
    logging: *default-logging
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      <<: *health-default

  nginx:
    logging: *default-logging
    healthcheck:
      test: ["CMD", "nginx", "-t"]
      <<: *health-default
```
