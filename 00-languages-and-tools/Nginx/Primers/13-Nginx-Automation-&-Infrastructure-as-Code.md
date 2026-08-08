# Primer 13: Nginx Automation & Infrastructure as Code

## The Target

This primer provides a comprehensive, deep-dive guide to automating Nginx deployments using Infrastructure as Code (IaC) principles. Understanding these concepts is essential for modern DevOps practices and continuous delivery.

## P13.1 Configuration Management

### Ansible Nginx Role

```yaml
# roles/nginx/tasks/main.yml
---
- name: Install Nginx
  apt:
    name: nginx
    state: present
  when: ansible_os_family == "Debian"

- name: Install Nginx (RHEL)
  yum:
    name: nginx
    state: present
  when: ansible_os_family == "RedHat"

- name: Create Nginx directories
  file:
    path: "{{ item }}"
    state: directory
    owner: nginx
    group: nginx
    mode: 0755
  loop:
    - /etc/nginx/conf.d
    - /etc/nginx/sites-available
    - /etc/nginx/sites-enabled
    - /etc/nginx/ssl
    - /var/cache/nginx
    - /var/log/nginx

- name: Copy Nginx configuration
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    owner: root
    group: root
    mode: 0644
  notify: restart nginx

- name: Copy site configurations
  template:
    src: site.conf.j2
    dest: /etc/nginx/sites-available/{{ site_name }}.conf
    owner: root
    group: root
    mode: 0644
  loop: "{{ sites }}"
  loop_control:
    loop_var: site
  notify: restart nginx

- name: Enable sites
  file:
    src: /etc/nginx/sites-available/{{ site_name }}.conf
    dest: /etc/nginx/sites-enabled/{{ site_name }}.conf
    state: link
  loop: "{{ sites }}"
  loop_control:
    loop_var: site
  notify: restart nginx

- name: Copy SSL certificates
  copy:
    src: "{{ item.src }}"
    dest: "{{ item.dest }}"
    owner: root
    group: root
    mode: 0600
  loop: "{{ ssl_certificates }}"
  when: ssl_certificates is defined
  notify: restart nginx

- name: Start Nginx
  service:
    name: nginx
    state: started
    enabled: yes
```

```yaml
# roles/nginx/templates/nginx.conf.j2
# nginx.conf.j2 - Dynamic Nginx configuration
worker_processes {{ worker_processes | default('auto') }};
worker_rlimit_nofile {{ worker_rlimit_nofile | default('65535') }};

error_log /var/log/nginx/error.log {{ error_log_level | default('warn') }};
pid /var/run/nginx.pid;

events {
    worker_connections {{ worker_connections | default('1024') }};
    use {{ event_model | default('epoll') }};
    multi_accept {{ multi_accept | default('on') }};
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    sendfile {{ sendfile | default('on') }};
    tcp_nopush {{ tcp_nopush | default('on') }};
    tcp_nodelay {{ tcp_nodelay | default('on') }};
    keepalive_timeout {{ keepalive_timeout | default('65') }};

    # Logging
    log_format json escape=json '{'
        '"timestamp":"$time_iso8601",'
        '"remote_addr":"$remote_addr",'
        '"request_id":"$request_id",'
        '"request_method":"$request_method",'
        '"request_uri":"$request_uri",'
        '"status":$status,'
        '"body_bytes_sent":$body_bytes_sent,'
        '"request_time":$request_time,'
        '"upstream_addr":"$upstream_addr",'
        '"upstream_status":$upstream_status,'
        '"upstream_response_time":$upstream_response_time"'
    '}';
    
    access_log /var/log/nginx/access.log json;

    # Include site configurations
    include /etc/nginx/sites-enabled/*.conf;
}
```

```yaml
# roles/nginx/templates/site.conf.j2
# site.conf.j2 - Dynamic site configuration
server {
    listen {{ site.listen_port | default('80') }};
    server_name {{ site.server_name }};

    {% if site.ssl_enabled %}
    listen 443 ssl http2;
    ssl_certificate /etc/nginx/ssl/{{ site.ssl_cert }};
    ssl_certificate_key /etc/nginx/ssl/{{ site.ssl_key }};
    {% endif %}

    {% if site.security_headers %}
    # Security Headers
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
    {% endif %}

    {% for location in site.locations %}
    location {{ location.path }} {
        {% if location.proxy_pass %}
        proxy_pass {{ location.proxy_pass }};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Request-ID $request_id;
        {% endif %}

        {% if location.rate_limit %}
        limit_req zone={{ location.rate_limit.zone }} burst={{ location.rate_limit.burst }} nodelay;
        {% endif %}

        {% if location.cache %}
        proxy_cache {{ location.cache.zone }};
        proxy_cache_valid {{ location.cache.valid }};
        {% endif %}

        {% if location.timeouts %}
        proxy_connect_timeout {{ location.timeouts.connect }};
        proxy_read_timeout {{ location.timeouts.read }};
        proxy_send_timeout {{ location.timeouts.send }};
        {% endif %}
    }
    {% endfor %}
}
```

### Terraform Nginx Module

```hcl
# modules/nginx/main.tf
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "nginx" {
  name         = "nginx:${var.nginx_version}"
  keep_locally = true
}

resource "docker_container" "nginx" {
  name  = var.container_name
  image = docker_image.nginx.image_id
  restart = "unless-stopped"
  
  ports {
    internal = 80
    external = var.http_port
  }
  
  ports {
    internal = 443
    external = var.https_port
  }
  
  volumes {
    host_path      = "${path.module}/nginx.conf"
    container_path = "/etc/nginx/nginx.conf"
    read_only      = true
  }
  
  volumes {
    host_path      = "${path.module}/conf.d"
    container_path = "/etc/nginx/conf.d"
    read_only      = true
  }
  
  volumes {
    host_path      = var.ssl_path
    container_path = "/etc/nginx/ssl"
    read_only      = true
  }
  
  volumes {
    host_path      = var.log_path
    container_path = "/var/log/nginx"
  }
  
  volumes {
    host_path      = var.cache_path
    container_path = "/var/cache/nginx"
  }
  
  networks_advanced {
    name = var.network_name
  }
  
  depends_on = var.depends_on
  
  healthcheck {
    test     = ["CMD", "curl", "-f", "http://localhost/health"]
    interval = "10s"
    timeout  = "5s"
    retries  = 3
    start_period = "30s"
  }
  
  dynamic "labels" {
    for_each = var.labels
    content {
      label = labels.key
      value = labels.value
    }
  }
}

output "container_id" {
  value = docker_container.nginx.id
}

output "container_name" {
  value = docker_container.nginx.name
}

output "ports" {
  value = {
    http  = var.http_port
    https = var.https_port
  }
}
```

```hcl
# modules/nginx/variables.tf
variable "nginx_version" {
  description = "Nginx version to use"
  type        = string
  default     = "1.27-alpine"
}

variable "container_name" {
  description = "Container name"
  type        = string
  default     = "nginx-proxy"
}

variable "http_port" {
  description = "HTTP port"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "HTTPS port"
  type        = number
  default     = 443
}

variable "ssl_path" {
  description = "Path to SSL certificates"
  type        = string
  default     = "./ssl"
}

variable "log_path" {
  description = "Path to logs"
  type        = string
  default     = "./logs"
}

variable "cache_path" {
  description = "Path to cache"
  type        = string
  default     = "./cache"
}

variable "network_name" {
  description = "Docker network name"
  type        = string
  default     = "app-network"
}

variable "depends_on" {
  description = "Services to depend on"
  type        = list(any)
  default     = []
}

variable "labels" {
  description = "Docker labels"
  type        = map(string)
  default     = {}
}
```

## P13.2 CI/CD Pipelines

### GitHub Actions Workflow

```yaml
# .github/workflows/deploy-nginx.yml
name: Deploy Nginx

on:
  push:
    branches:
      - main
    paths:
      - 'nginx/**'
      - 'nginx.conf'
      - 'terraform/**'
  workflow_dispatch:

env:
  DOCKER_REGISTRY: ghcr.io
  DOCKER_IMAGE: ${{ github.repository }}/nginx

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Login to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ${{ env.DOCKER_REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: ./nginx
          push: true
          tags: |
            ${{ env.DOCKER_IMAGE }}:${{ github.sha }}
            ${{ env.DOCKER_IMAGE }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Docker Compose
        run: |
          docker compose -f docker-compose.test.yml up -d
          sleep 10

      - name: Run tests
        run: |
          ./scripts/test-nginx.sh
          ./scripts/validate-config.sh

      - name: Clean up
        run: docker compose -f docker-compose.test.yml down -v

  deploy-dev:
    needs: test
    runs-on: ubuntu-latest
    environment: dev
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0

      - name: Terraform Init
        run: terraform -chdir=terraform/dev init

      - name: Terraform Plan
        run: terraform -chdir=terraform/dev plan

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform -chdir=terraform/dev apply -auto-approve

  deploy-prod:
    needs: deploy-dev
    runs-on: ubuntu-latest
    environment: prod
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0

      - name: Terraform Init
        run: terraform -chdir=terraform/prod init

      - name: Terraform Plan
        run: terraform -chdir=terraform/prod plan

      - name: Terraform Apply
        run: terraform -chdir=terraform/prod apply -auto-approve

  validate:
    needs: deploy-prod
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Validate deployment
        run: |
          ./scripts/health-check.sh
          ./scripts/security-audit.sh
```

### GitLab CI/CD Pipeline

```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - deploy
  - validate

variables:
  DOCKER_REGISTRY: registry.gitlab.com
  DOCKER_IMAGE: $CI_PROJECT_PATH/nginx

build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t $DOCKER_IMAGE:$CI_COMMIT_SHA ./nginx
    - docker tag $DOCKER_IMAGE:$CI_COMMIT_SHA $DOCKER_IMAGE:latest
    - docker push $DOCKER_IMAGE:$CI_COMMIT_SHA
    - docker push $DOCKER_IMAGE:latest

test:
  stage: test
  image: docker/compose:latest
  services:
    - docker:dind
  script:
    - docker compose -f docker-compose.test.yml up -d
    - sleep 10
    - ./scripts/test-nginx.sh
    - ./scripts/validate-config.sh
  after_script:
    - docker compose -f docker-compose.test.yml down -v

deploy-dev:
  stage: deploy
  image: hashicorp/terraform:1.5.0
  script:
    - cd terraform/dev
    - terraform init
    - terraform plan
    - terraform apply -auto-approve
  environment:
    name: dev
    url: https://dev.example.com
  only:
    - main

deploy-prod:
  stage: deploy
  image: hashicorp/terraform:1.5.0
  script:
    - cd terraform/prod
    - terraform init
    - terraform plan
    - terraform apply -auto-approve
  environment:
    name: prod
    url: https://example.com
  only:
    - tags
  when: manual

validate:
  stage: validate
  image: alpine:latest
  script:
    - apk add --no-cache curl jq
    - ./scripts/health-check.sh
    - ./scripts/security-audit.sh
  environment:
    name: prod
  only:
    - tags
  when: manual
```

## P13.3 Kubernetes Deployment Automation

### Helm Chart

```yaml
# helm/nginx/values.yaml
replicaCount: 3

image:
  repository: nginx
  tag: 1.27-alpine
  pullPolicy: IfNotPresent

service:
  type: LoadBalancer
  port: 80
  targetPort: 80
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"

ingress:
  enabled: true
  className: nginx
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
  hosts:
    - host: example.com
      paths:
        - path: /
          pathType: Prefix

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 250m
    memory: 256Mi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80

config:
  worker_processes: auto
  worker_connections: 1024
  keepalive_timeout: 65
  gzip: on
  gzip_comp_level: 6

security:
  hsts: true
  hsts_max_age: 63072000
  x_frame_options: DENY
  x_content_type_options: nosniff

ssl:
  enabled: true
  certSecret: nginx-tls

monitoring:
  enabled: true
  prometheus:
    metricsPath: /metrics
    port: 9113
```

```yaml
# helm/nginx/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "nginx.fullname" . }}
  labels:
    {{- include "nginx.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "nginx.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "nginx.selectorLabels" . | nindent 8 }}
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
    spec:
      containers:
      - name: nginx
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: 80
          name: http
        - containerPort: 443
          name: https
        - containerPort: 9113
          name: metrics
        volumeMounts:
        - name: config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
          readOnly: true
        - name: confd
          mountPath: /etc/nginx/conf.d
          readOnly: true
        {{- if .Values.ssl.enabled }}
        - name: ssl
          mountPath: /etc/nginx/ssl
          readOnly: true
        {{- end }}
        - name: cache
          mountPath: /var/cache/nginx
        - name: logs
          mountPath: /var/log/nginx
        resources:
          {{- toYaml .Values.resources | nindent 10 }}
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 20
        readinessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
        lifecycle:
          preStop:
            exec:
              command: ["/bin/sh", "-c", "sleep 5"]
      volumes:
      - name: config
        configMap:
          name: {{ include "nginx.fullname" . }}-config
      - name: confd
        configMap:
          name: {{ include "nginx.fullname" . }}-confd
      {{- if .Values.ssl.enabled }}
      - name: ssl
        secret:
          secretName: {{ .Values.ssl.certSecret }}
      {{- end }}
      - name: cache
        emptyDir: {}
      - name: logs
        emptyDir: {}
```

```yaml
# helm/nginx/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "nginx.fullname" . }}-config
  labels:
    {{- include "nginx.labels" . | nindent 4 }}
data:
  nginx.conf: |
    worker_processes {{ .Values.config.worker_processes }};
    error_log /var/log/nginx/error.log warn;
    pid /var/run/nginx.pid;

    events {
        worker_connections {{ .Values.config.worker_connections }};
        use epoll;
        multi_accept on;
    }

    http {
        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout {{ .Values.config.keepalive_timeout }};

        # Security Headers
        {{- if .Values.security.hsts }}
        add_header Strict-Transport-Security "max-age={{ .Values.security.hsts_max_age }}; includeSubDomains; preload" always;
        {{- end }}
        add_header X-Content-Type-Options "{{ .Values.security.x_content_type_options }}" always;
        add_header X-Frame-Options "{{ .Values.security.x_frame_options }}" always;
        add_header X-XSS-Protection "1; mode=block" always;

        # Rate Limiting
        limit_req_zone $binary_remote_addr zone=global:10m rate=100r/m;
        limit_req_zone $binary_remote_addr zone=api:10m rate=60r/m;

        # Caching
        proxy_cache_path /var/cache/nginx/api_cache levels=1:2 keys_zone=api_cache:100m max_size=1g inactive=1h use_temp_path=off;
        proxy_cache_path /var/cache/nginx/static_cache levels=1:2 keys_zone=static_cache:50m max_size=500m inactive=30d use_temp_path=off;

        # Upstreams
        upstream backend {
            server backend-service:8000 max_fails=3 fail_timeout=30s;
            keepalive 32;
        }

        # Main Server
        server {
            listen 80;
            listen [::]:80;
            server_name _;

            limit_req zone=global burst=20 nodelay;

            location / {
                proxy_pass http://backend;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_set_header X-Request-ID $request_id;
            }

            location /health {
                access_log off;
                return 200 "healthy\n";
            }

            location /metrics {
                stub_status on;
                access_log off;
                allow 127.0.0.1;
                allow 10.0.0.0/8;
                deny all;
            }
        }
    }
```

## P13.4 Automation Scripts

### Deployment Script

**File: `deploy-nginx.sh`**

```bash
#!/bin/bash
# deploy-nginx.sh - Complete deployment automation

set -e

echo "=== Nginx Deployment Automation ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Function to log messages
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✓ $1${NC}"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ✗ $1${NC}"
}

# Step 1: Backup current configuration
log "Step 1: Backing up current configuration"
BACKUP_DIR="./backups/nginx_$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR
cp -r /etc/nginx $BACKUP_DIR/ 2>/dev/null || true
cp -r ./nginx.conf $BACKUP_DIR/ 2>/dev/null || true
log_success "Backup created at $BACKUP_DIR"

# Step 2: Validate configuration
log "Step 2: Validating configuration"
nginx -t
if [ $? -ne 0 ]; then
    log_error "Configuration validation failed!"
    exit 1
fi
log_success "Configuration validation passed"

# Step 3: Build Docker image
log "Step 3: Building Docker image"
docker build -t nginx-prod:latest ./nginx
log_success "Docker image built"

# Step 4: Tag and push
log "Step 4: Tagging and pushing image"
docker tag nginx-prod:latest ${REGISTRY}/nginx-prod:${TAG:-latest}
docker push ${REGISTRY}/nginx-prod:${TAG:-latest}
log_success "Image pushed to registry"

# Step 5: Deploy using Kubernetes
log "Step 5: Deploying to Kubernetes"
kubectl apply -f kubernetes/nginx-deployment.yaml
kubectl apply -f kubernetes/nginx-service.yaml
kubectl apply -f kubernetes/nginx-ingress.yaml
kubectl rollout status deployment/nginx-prod -n production
log_success "Deployment complete"

# Step 6: Verify deployment
log "Step 6: Verifying deployment"
sleep 10
kubectl get pods -n production -l app=nginx-prod
kubectl get svc -n production nginx-prod
kubectl get ingress -n production

# Step 7: Health check
log "Step 7: Running health check"
./scripts/health-check.sh
if [ $? -eq 0 ]; then
    log_success "Health check passed"
else
    log_error "Health check failed"
    exit 1
fi

# Step 8: Run security tests
log "Step 8: Running security tests"
./scripts/security-audit.sh
log_success "Security tests complete"

# Step 9: Performance test
if [ "$RUN_PERFORMANCE_TESTS" = "true" ]; then
    log "Step 9: Running performance tests"
    ./scripts/performance-test.sh
    log_success "Performance tests complete"
fi

log_success "Deployment completed successfully!"
```

### Zero-Downtime Reload Script

**File: `zero-downtime-reload.sh`**

```bash
#!/bin/bash
# zero-downtime-reload.sh - Zero-downtime reload

echo "=== Zero-Downtime Reload ==="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to check connections
check_connections() {
    if [ -f /var/run/nginx.pid ]; then
        CONNS=$(netstat -an | grep ':443' | grep ESTABLISHED | wc -l)
        echo -e "${YELLOW}Active connections: $CONNS${NC}"
    fi
}

# 1. Check current connections
echo "1. Current connections:"
check_connections

# 2. Test configuration
echo ""
echo "2. Testing configuration..."
nginx -t
if [ $? -ne 0 ]; then
    echo "Configuration test failed!"
    exit 1
fi

# 3. Start new workers
echo ""
echo "3. Starting new workers..."
nginx -s reload

# 4. Wait for reload to complete
echo ""
echo "4. Waiting for reload to complete..."
sleep 2

# 5. Check new connections
echo ""
echo "5. New connections:"
check_connections

# 6. Verify worker processes
echo ""
echo "6. Worker processes:"
ps aux | grep nginx | grep worker

# 7. Check logs for errors
echo ""
echo "7. Checking logs for errors:"
tail -20 /var/log/nginx/error.log | grep -i "error" || echo "No errors found"

echo ""
echo -e "${GREEN}Reload complete!${NC}"
```

---

This primer provides a comprehensive deep dive into automating Nginx deployments using Infrastructure as Code principles. Use these techniques to implement CI/CD pipelines, automate deployments, and achieve continuous delivery.
