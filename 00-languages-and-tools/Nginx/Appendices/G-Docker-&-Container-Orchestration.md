# Appendix G: Docker & Container Orchestration

## The Target

This appendix provides comprehensive guidance for running Nginx in Docker and container orchestration environments. Whether you're using Docker Compose, Kubernetes, or Swarm, this guide covers everything you need to know.

## G.1 Docker Fundamentals

### Base Nginx Image

```dockerfile
# Official Nginx image with Alpine (lightweight)
FROM nginx:1.27-alpine

# Install additional packages if needed
RUN apk add --no-cache curl openssl

# Copy configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/* /etc/nginx/conf.d/
COPY ssl/* /etc/nginx/ssl/

# Create cache directories
RUN mkdir -p /var/cache/nginx && \
    chown -R nginx:nginx /var/cache/nginx

# Health check
HEALTHCHECK --interval=10s --timeout=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
```

### Optimized Dockerfile

```dockerfile
# Multi-stage build for smaller image
FROM nginx:1.27-alpine as builder

# Build custom Nginx with modules
RUN apk add --no-cache \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre-dev \
    zlib-dev \
    linux-headers \
    curl \
    gnupg \
    libxslt-dev \
    gd-dev \
    geoip-dev

# Download and build Nginx with additional modules
RUN wget http://nginx.org/download/nginx-1.27.0.tar.gz && \
    tar -xzf nginx-1.27.0.tar.gz && \
    cd nginx-1.27.0 && \
    ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-compat \
        --with-file-aio \
        --with-threads \
        --with-http_addition_module \
        --with-http_auth_request_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_mp4_module \
        --with-http_random_index_module \
        --with-http_realip_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_sub_module \
        --with-http_v2_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-stream \
        --with-stream_realip_module \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module && \
    make && make install

# Final stage
FROM alpine:3.19

# Install runtime dependencies
RUN apk add --no-cache \
    openssl \
    pcre \
    zlib \
    curl

# Copy built Nginx
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /usr/lib/nginx /usr/lib/nginx

# Create necessary directories
RUN mkdir -p /var/cache/nginx /var/log/nginx && \
    addgroup -S nginx && adduser -S nginx -G nginx && \
    chown -R nginx:nginx /var/cache/nginx /var/log/nginx

# Copy configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/ /etc/nginx/conf.d/
COPY ssl/ /etc/nginx/ssl/

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
```

## G.2 Docker Compose Configuration

### Complete Docker Compose

**File: `docker-compose.yml`**

```yaml
version: '3.8'

services:
  nginx:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: nginx-prod
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      # Configuration
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./conf.d:/etc/nginx/conf.d:ro
      - ./ssl:/etc/nginx/ssl:ro
      # Runtime data
      - ./logs:/var/log/nginx
      - ./cache:/var/cache/nginx
      - ./html:/usr/share/nginx/html
      # Templates
      - ./templates:/etc/nginx/templates
    environment:
      - NGINX_HOST=example.com
      - NGINX_PORT=443
    networks:
      - app-network
    depends_on:
      - backend
      - auth
    healthcheck:
      test: ["CMD", "curl", "-f", "https://localhost/health"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 30s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 512M

  backend:
    build: ./backend
    container_name: backend
    restart: unless-stopped
    environment:
      - NODE_ENV=production
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 30s

  auth:
    build: ./auth
    container_name: auth
    restart: unless-stopped
    environment:
      - NODE_ENV=production
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8001/health"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 30s

networks:
  app-network:
    driver: bridge
    name: nginx-network

volumes:
  logs:
    driver: local
  cache:
    driver: local
  html:
    driver: local
```

### Environment-Specific Configurations

**File: `docker-compose.override.yml`**

```yaml
version: '3.8'

services:
  nginx:
    # Development overrides
    ports:
      - "8080:80"
      - "8443:443"
    environment:
      - NGINX_HOST=localhost
      - NGINX_PORT=443
    volumes:
      - ./nginx-dev.conf:/etc/nginx/nginx.conf:ro
      - ./ssl-dev:/etc/nginx/ssl:ro
```

### Production-Ready Compose

**File: `docker-compose.prod.yml`**

```yaml
version: '3.8'

services:
  nginx:
    image: ${REGISTRY}/nginx:${TAG}
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - nginx-logs:/var/log/nginx
      - nginx-cache:/var/cache/nginx
    environment:
      - NGINX_HOST=${DOMAIN}
    networks:
      - app-network
    depends_on:
      - backend
    deploy:
      mode: replicated
      replicas: 2
      update_config:
        parallelism: 1
        delay: 10s
        order: start-first
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 512M

networks:
  app-network:
    driver: overlay
    attachable: true

volumes:
  nginx-logs:
    driver: local
  nginx-cache:
    driver: local
```

## G.3 Kubernetes Configuration

### Nginx Deployment

**File: `nginx-deployment.yaml`**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-proxy
  namespace: production
  labels:
    app: nginx-proxy
    tier: ingress
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: nginx-proxy
  template:
    metadata:
      labels:
        app: nginx-proxy
        tier: ingress
    spec:
      containers:
      - name: nginx
        image: nginx:1.27-alpine
        ports:
        - containerPort: 80
        - containerPort: 443
        volumeMounts:
        - name: nginx-config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
        - name: nginx-confd
          mountPath: /etc/nginx/conf.d
        - name: nginx-ssl
          mountPath: /etc/nginx/ssl
          readOnly: true
        - name: nginx-cache
          mountPath: /var/cache/nginx
        - name: nginx-logs
          mountPath: /var/log/nginx
        env:
        - name: NGINX_HOST
          valueFrom:
            configMapKeyRef:
              name: nginx-config
              key: host
        readinessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 20
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "1"
      volumes:
      - name: nginx-config
        configMap:
          name: nginx-config
      - name: nginx-confd
        configMap:
          name: nginx-confd
      - name: nginx-ssl
        secret:
          secretName: nginx-ssl
      - name: nginx-cache
        persistentVolumeClaim:
          claimName: nginx-cache
      - name: nginx-logs
        persistentVolumeClaim:
          claimName: nginx-logs
```

### Nginx Service

**File: `nginx-service.yaml`**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-proxy
  namespace: production
  labels:
    app: nginx-proxy
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "arn:aws:acm:..."
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "443"
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
spec:
  type: LoadBalancer
  selector:
    app: nginx-proxy
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
  - name: https
    port: 443
    targetPort: 443
    protocol: TCP
  externalTrafficPolicy: Local
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 3600
```

### Nginx Ingress Controller

**File: `nginx-ingress.yaml`**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: production
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "60"
    nginx.ingress.kubernetes.io/configuration-snippet: |
      more_set_headers "X-Frame-Options: DENY";
      more_set_headers "X-Content-Type-Options: nosniff";
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - app.example.com
    secretName: app-tls
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8000
      - path: /auth
        pathType: Prefix
        backend:
          service:
            name: auth-service
            port:
              number: 8001
```

### ConfigMaps and Secrets

**File: `nginx-config.yaml`**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: production
data:
  nginx.conf: |
    events {
      worker_connections 1024;
    }
    http {
      include /etc/nginx/mime.types;
      default_type application/octet-stream;
      
      log_format json escape=json '{'
        '"timestamp":"$time_iso8601",'
        '"remote_addr":"$remote_addr",'
        '"request_id":"$request_id",'
        '"request_method":"$request_method",'
        '"request_uri":"$request_uri",'
        '"status":$status,'
        '"request_time":$request_time'
      '}';
      
      access_log /var/log/nginx/access.log json;
      error_log /var/log/nginx/error.log warn;
      
      server {
        listen 80;
        server_name localhost;
        
        location / {
          proxy_pass http://frontend-service;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Request-ID $request_id;
        }
        
        location /api/ {
          proxy_pass http://api-service/;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Request-ID $request_id;
        }
      }
    }
  host: "app.example.com"
```

### Persistent Volumes

**File: `nginx-pvc.yaml`**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nginx-cache
  namespace: production
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: gp2
  resources:
    requests:
      storage: 10Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nginx-logs
  namespace: production
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: gp2
  resources:
    requests:
      storage: 20Gi
```

## G.4 Docker Swarm Configuration

**File: `docker-stack.yml`**

```yaml
version: '3.8'

services:
  nginx:
    image: nginx:1.27-alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - nginx-config:/etc/nginx/conf.d
      - nginx-ssl:/etc/nginx/ssl
      - nginx-logs:/var/log/nginx
    configs:
      - source: nginx.conf
        target: /etc/nginx/nginx.conf
    secrets:
      - source: ssl_key
        target: /etc/nginx/ssl/key.pem
      - source: ssl_cert
        target: /etc/nginx/ssl/cert.pem
    networks:
      - app-network
    deploy:
      mode: replicated
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: any
        delay: 5s
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 256M

configs:
  nginx.conf:
    file: ./nginx.conf

secrets:
  ssl_key:
    file: ./ssl/server.key
  ssl_cert:
    file: ./ssl/server.crt

networks:
  app-network:
    driver: overlay
```

## G.5 Container Best Practices

### Security Best Practices

```dockerfile
# Security-hardened Dockerfile

# Use non-root user
FROM nginx:1.27-alpine

# Create nginx user if not exists
RUN addgroup -S nginx && adduser -S nginx -G nginx

# Set ownership
COPY --chown=nginx:nginx nginx.conf /etc/nginx/nginx.conf
COPY --chown=nginx:nginx conf.d/ /etc/nginx/conf.d/

# Drop unnecessary capabilities
RUN setcap 'cap_net_bind_service=+ep' /usr/sbin/nginx

# Secure file permissions
RUN chmod 600 /etc/nginx/ssl/*.key && \
    chmod 644 /etc/nginx/ssl/*.crt

# Use read-only filesystem
VOLUME ["/var/cache/nginx", "/var/log/nginx"]

USER nginx

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
```

### Health Checks

```yaml
# Docker Compose health check
healthcheck:
  test: ["CMD-SHELL", "wget --spider -q http://localhost/health || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 30s
```

### Logging Configuration

```yaml
# Docker Compose logging
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "5"
    labels: "production,nginx"
    env: "NGINX_HOST"
```

### Resource Limits

```yaml
# Docker Compose resources
deploy:
  resources:
    limits:
      cpus: '2.0'
      memory: 2G
    reservations:
      cpus: '0.5'
      memory: 256M
```

## G.6 Deployment Scripts

### Docker Deploy Script

**File: `deploy-docker.sh`**

```bash
#!/bin/bash
# deploy-docker.sh - Docker deployment

set -e

echo "=== Docker Deployment ==="

# Build image
echo "Building image..."
docker build -t nginx-proxy:latest .

# Tag for registry
docker tag nginx-proxy:latest ${REGISTRY}/nginx-proxy:${TAG}

# Push to registry
echo "Pushing to registry..."
docker push ${REGISTRY}/nginx-proxy:${TAG}

# Deploy with compose
echo "Deploying services..."
docker stack deploy -c docker-compose.prod.yml nginx-stack

# Verify deployment
echo "Verifying deployment..."
docker stack services nginx-stack

echo "Deployment complete!"
```

### Kubernetes Deploy Script

**File: `deploy-k8s.sh`**

```bash
#!/bin/bash
# deploy-k8s.sh - Kubernetes deployment

set -e

echo "=== Kubernetes Deployment ==="

# Apply configs
echo "Applying configs..."
kubectl apply -f nginx-config.yaml
kubectl apply -f nginx-secrets.yaml
kubectl apply -f nginx-pvc.yaml

# Apply deployment
echo "Applying deployment..."
kubectl apply -f nginx-deployment.yaml

# Apply service
echo "Applying service..."
kubectl apply -f nginx-service.yaml

# Wait for rollout
echo "Waiting for rollout..."
kubectl rollout status deployment/nginx-proxy -n production

# Apply ingress
echo "Applying ingress..."
kubectl apply -f nginx-ingress.yaml

# Get service info
echo "Service endpoints:"
kubectl get svc -n production

echo "Deployment complete!"
```

## G.7 Monitoring & Logging

### Container Logging

```bash
# Docker logs
docker logs -f nginx-proxy

# Docker logs with timestamps
docker logs -t nginx-proxy

# Compose logs
docker compose logs -f nginx

# Kubernetes logs
kubectl logs -f -n production deployment/nginx-proxy

# Kubernetes logs with label filter
kubectl logs -f -n production -l app=nginx-proxy
```

### Log Aggregation

**File: `docker-compose.logging.yml`**

```yaml
version: '3.8'

services:
  nginx:
    logging:
      driver: "fluentd"
      options:
        fluentd-address: "localhost:24224"
        tag: "nginx.{{.Name}}"
        labels: "production,nginx"

  fluentd:
    image: fluentd:latest
    volumes:
      - ./fluentd.conf:/fluentd/etc/fluentd.conf
    ports:
      - "24224:24224"
      - "24224:24224/udp"

  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.10.0
    environment:
      - discovery.type=single-node
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data

  kibana:
    image: docker.elastic.co/kibana/kibana:8.10.0
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch

volumes:
  elasticsearch-data:
```

### Monitoring with Prometheus

**File: `nginx-prometheus.conf`**

```nginx
# nginx.conf with Prometheus metrics
location /metrics {
    # Only internal access
    allow 127.0.0.1;
    allow 10.0.0.0/8;
    deny all;
    
    # Enable metrics
    stub_status on;
    access_log off;
    
    # Prometheus format conversion
    # Use nginx-prometheus-exporter
}
```

**File: `prometheus.yml`**

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx:9113']
    metrics_path: '/metrics'
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: prometheus:9090
```

## G.8 Troubleshooting Guide

### Common Container Issues

| Issue | Symptoms | Resolution |
|-------|----------|------------|
| Container won't start | `docker run` fails | Check logs: `docker logs <container>` |
| Port conflict | Address already in use | Change host port mapping |
| Volume permission denied | Permission errors | Check user/group in container |
| Config not loaded | Default config served | Verify volume mount path |
| Certificates invalid | SSL errors | Check certificate paths/permissions |

### Debugging Commands

```bash
# Check container status
docker ps -a
kubectl get pods -n production

# View container logs
docker logs -f nginx-proxy
kubectl logs -f nginx-pod

# Execute commands in container
docker exec -it nginx-proxy /bin/sh
kubectl exec -it nginx-pod -- /bin/sh

# Check configuration
docker exec nginx-proxy nginx -t
kubectl exec nginx-pod -- nginx -t

# View configuration
docker exec nginx-proxy nginx -T
kubectl exec nginx-pod -- nginx -T

# Reload configuration
docker exec nginx-proxy nginx -s reload
kubectl exec nginx-pod -- nginx -s reload

# Check network connectivity
docker exec nginx-proxy ping backend
kubectl exec nginx-pod -- ping backend-service

# Check mounted volumes
docker inspect nginx-proxy | grep -A10 Mounts
kubectl describe pod nginx-pod
```

---

This appendix provides everything you need to run Nginx in containerized environments. The patterns and configurations are production-tested and can be adapted to your specific deployment requirements.
