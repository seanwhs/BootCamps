# Primer 10: Nginx for Cloud & Container Orchestration

## The Target

This primer provides a comprehensive, deep-dive guide to running Nginx in cloud environments and container orchestration platforms. Understanding these concepts is essential for modern cloud-native deployments.

## P10.1 Cloud Provider Integration

### AWS Integration

```nginx
# nginx.conf - AWS ELB integration
http {
    # Use ELB health check path
    location /health {
        access_log off;
        return 200 "healthy\n";
    }
    
    # AWS-specific headers
    location / {
        # Get real client IP from ELB
        set_real_ip_from 10.0.0.0/8;
        set_real_ip_from 172.16.0.0/12;
        set_real_ip_from 192.168.0.0/16;
        real_ip_header X-Forwarded-For;
        real_ip_recursive on;
        
        # Forward AWS headers
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
        
        proxy_pass http://backend/;
    }
}
```

### Google Cloud Platform (GCP)

```nginx
# nginx.conf - GCP integration
http {
    # GCP health check
    location /healthz {
        access_log off;
        return 200 "ok";
    }
    
    # GCP load balancer headers
    location / {
        set_real_ip_from 130.211.0.0/22;
        set_real_ip_from 35.191.0.0/16;
        real_ip_header X-Forwarded-For;
        
        # GCP-specific headers
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Cloud-Trace-Context $http_x_cloud_trace_context;
        
        proxy_pass http://backend/;
    }
}
```

### Azure Integration

```nginx
# nginx.conf - Azure integration
http {
    # Azure health check
    location /health {
        access_log off;
        return 200 "OK";
    }
    
    # Azure load balancer headers
    location / {
        set_real_ip_from 168.63.129.16;
        set_real_ip_from 169.254.169.254;
        real_ip_header X-Forwarded-For;
        
        # Azure-specific headers
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Original-URL $request_uri;
        
        proxy_pass http://backend/;
    }
}
```

## P10.2 Kubernetes Integration

### Kubernetes Ingress Controller

```nginx
# nginx-ingress-controller configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-configuration
  namespace: ingress-nginx
data:
  # SSL/TLS Configuration
  ssl-protocols: "TLSv1.2 TLSv1.3"
  ssl-ciphers: "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384"
  ssl-session-cache: "true"
  
  # Security Headers
  hsts: "true"
  hsts-include-subdomains: "true"
  hsts-max-age: "63072000"
  
  # Logging
  log-format-upstream: '{"timestamp":"$time_iso8601","remote_addr":"$remote_addr","request_id":"$req_id","request":"$request","status":$status,"body_bytes_sent":$body_bytes_sent,"request_time":$request_time,"upstream_addr":"$upstream_addr","upstream_status":$upstream_status,"upstream_response_time":$upstream_response_time}'
  
  # Rate Limiting
  limit-req-zone-name: "global"
  limit-req-zone-key: "$binary_remote_addr"
  limit-req-zone-size: "10m"
  limit-req-zone-rate: "10r/s"
  limit-req-zone-burst: "20"
```

### Kubernetes Service Configuration

```yaml
# nginx-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-proxy
  namespace: production
  labels:
    app: nginx-proxy
  annotations:
    # AWS Load Balancer
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "arn:aws:acm:..."
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "443"
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
    
    # GCP Load Balancer
    cloud.google.com/load-balancer-type: "External"
    cloud.google.com/neg: '{"ingress": true}'
    
    # Azure Load Balancer
    service.beta.kubernetes.io/azure-load-balancer-internal: "false"
    service.beta.kubernetes.io/azure-load-balancer-tcp-idle-timeout: "4"
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

### Kubernetes Ingress Resource

```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: production
  annotations:
    kubernetes.io/ingress.class: nginx
    
    # SSL/TLS
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    
    # Security Headers
    nginx.ingress.kubernetes.io/configuration-snippet: |
      add_header X-Content-Type-Options "nosniff";
      add_header X-Frame-Options "DENY";
      add_header X-XSS-Protection "1; mode=block";
      add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
    
    # Rate Limiting
    nginx.ingress.kubernetes.io/limit-rps: "10"
    nginx.ingress.kubernetes.io/limit-burst: "20"
    nginx.ingress.kubernetes.io/limit-whitelist: "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
    
    # CORS
    nginx.ingress.kubernetes.io/enable-cors: "true"
    nginx.ingress.kubernetes.io/cors-allow-origin: "https://example.com"
    nginx.ingress.kubernetes.io/cors-allow-methods: "GET, POST, PUT, DELETE, OPTIONS"
    nginx.ingress.kubernetes.io/cors-allow-headers: "Authorization, Content-Type"
    
    # Rewrite
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/configuration-snippet: |
      rewrite ^/old-path/(.*)$ /new-path/$1 permanent;
    
    # Cache
    nginx.ingress.kubernetes.io/proxy-buffering: "on"
    nginx.ingress.kubernetes.io/proxy-buffer-size: "8k"
    nginx.ingress.kubernetes.io/proxy-buffers: "8 8k"
    
    # Timeouts
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "10s"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "60s"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "60s"
    
    # Body Size
    nginx.ingress.kubernetes.io/proxy-body-size: "10M"
    
    # Websocket
    nginx.ingress.kubernetes.io/proxy-read-timeout: "300s"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "300s"
spec:
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
      - path: /ws
        pathType: Prefix
        backend:
          service:
            name: websocket-service
            port:
              number: 8002
```

## P10.3 Service Mesh Integration

### Istio Integration

```yaml
# istio-gateway.yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: nginx-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*.example.com"
    tls:
      httpsRedirect: true
  - port:
      number: 443
      name: https
      protocol: HTTPS
    hosts:
    - "*.example.com"
    tls:
      mode: SIMPLE
      credentialName: nginx-cert
```

```yaml
# virtual-service.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: nginx-routes
  namespace: default
spec:
  hosts:
  - "app.example.com"
  gateways:
  - istio-system/nginx-gateway
  http:
  - match:
    - uri:
        prefix: /api/
    route:
    - destination:
        host: api-service
        port:
          number: 8000
      weight: 90
    - destination:
        host: api-service-v2
        port:
          number: 8001
      weight: 10
  - match:
    - uri:
        prefix: /ws/
    route:
    - destination:
        host: websocket-service
        port:
          number: 8002
    timeout: 300s
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: frontend-service
        port:
          number: 80
```

## P10.4 Docker Swarm Integration

### Docker Stack Configuration

```yaml
# docker-stack.yml
version: '3.8'

services:
  nginx:
    image: nginx:1.27-alpine
    ports:
      - "80:80"
      - "443:443"
    configs:
      - source: nginx_conf
        target: /etc/nginx/nginx.conf
    secrets:
      - source: ssl_cert
        target: /etc/nginx/ssl/cert.pem
      - source: ssl_key
        target: /etc/nginx/ssl/key.pem
    networks:
      - app-network
    deploy:
      mode: replicated
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
        order: start-first
      restart_policy:
        condition: any
        delay: 5s
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 256M
      placement:
        constraints:
          - node.role == worker
          - node.labels.nginx == true
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.nginx.rule=Host(`example.com`)"
        - "traefik.http.services.nginx.loadbalancer.server.port=80"

configs:
  nginx_conf:
    file: ./nginx.conf

secrets:
  ssl_cert:
    file: ./ssl/cert.pem
  ssl_key:
    file: ./ssl/key.pem

networks:
  app-network:
    driver: overlay
    attachable: true
```

## P10.5 Horizontal Pod Autoscaling

### HPA Configuration

```yaml
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-proxy
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  - type: Pods
    pods:
      metric:
        name: nginx_http_requests_total
      target:
        type: AverageValue
        averageValue: "100"
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Pods
        value: 1
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Pods
        value: 2
        periodSeconds: 60
      - type: Percent
        value: 50
        periodSeconds: 60
      selectPolicy: Max
```

### Vertical Pod Autoscaler

```yaml
# vpa.yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: nginx-vpa
  namespace: production
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-proxy
  updatePolicy:
    updateMode: "Auto"
  resourcePolicy:
    containerPolicies:
    - containerName: nginx
      minAllowed:
        cpu: "100m"
        memory: "256Mi"
      maxAllowed:
        cpu: "2"
        memory: "2Gi"
      controlledResources: ["cpu", "memory"]
```

## P10.6 Cloud Storage Integration

### AWS S3 Static Content

```nginx
# nginx.conf - S3 integration
http {
    # S3 bucket as upstream
    resolver 169.254.169.253 valid=10s;
    
    location /static/ {
        set $s3_bucket "my-bucket.s3.amazonaws.com";
        proxy_pass http://$s3_bucket/static/;
        
        # S3-specific headers
        proxy_set_header Host $s3_bucket;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        
        # Cache control
        expires 30d;
        add_header Cache-Control "public, immutable";
        
        # S3 authentication (if needed)
        proxy_set_header Authorization "AWS $aws_access_key:$aws_signature";
    }
}
```

### Azure Blob Storage

```nginx
# nginx.conf - Azure Blob integration
http {
    location /static/ {
        set $azure_storage "myaccount.blob.core.windows.net";
        proxy_pass https://$azure_storage/mycontainer/;
        
        # Azure-specific headers
        proxy_set_header Host $azure_storage;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        
        # Cache control
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

### Google Cloud Storage

```nginx
# nginx.conf - GCS integration
http {
    location /static/ {
        set $gcs_bucket "storage.googleapis.com";
        proxy_pass https://$gcs_bucket/my-bucket/;
        
        # GCS-specific headers
        proxy_set_header Host $gcs_bucket;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        
        # Cache control
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

---

This primer provides a comprehensive deep dive into running Nginx in cloud environments and container orchestration platforms. Use these patterns to deploy Nginx in any cloud-native environment.
