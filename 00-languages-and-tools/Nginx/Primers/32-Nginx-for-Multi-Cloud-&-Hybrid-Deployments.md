# Primer 32: Nginx for Multi-Cloud & Hybrid Deployments

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx for multi-cloud and hybrid cloud deployments. Understanding these concepts is essential for building resilient, portable, and cost-optimized cloud architectures.

## P32.1 Multi-Cloud Architecture

### Multi-Cloud Deployment Model

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    MULTI-CLOUD ARCHITECTURE                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                         ┌─────────────────────┐                           │
│                         │   Global DNS        │                           │
│                         │   (AWS Route 53/    │                           │
│                         │    GCP Cloud DNS)   │                           │
│                         └──────────┬──────────┘                           │
│                                    │                                       │
│              ┌─────────────────────┼─────────────────────┐                │
│              │                     │                     │                │
│              ▼                     ▼                     ▼                │
│  ┌───────────────────┐  ┌───────────────────┐  ┌───────────────────┐    │
│  │   AWS Region      │  │   GCP Region      │  │   Azure Region    │    │
│  │   (us-east-1)     │  │   (us-central1)   │  │   (eastus)        │    │
│  │  ┌─────────────┐  │  │  ┌─────────────┐  │  │  ┌─────────────┐  │    │
│  │  │  Nginx HA   │  │  │  │  Nginx HA   │  │  │  │  Nginx HA   │  │    │
│  │  │  (Active)   │  │  │  │  (Active)   │  │  │  │  (Active)   │  │    │
│  │  └─────────────┘  │  │  └─────────────┘  │  │  └─────────────┘  │    │
│  │  ┌─────────────┐  │  │  ┌─────────────┐  │  │  ┌─────────────┐  │    │
│  │  │  Backend    │  │  │  │  Backend    │  │  │  │  Backend    │  │    │
│  │  │  Services   │  │  │  │  Services   │  │  │  │  Services   │  │    │
│  │  └─────────────┘  │  │  └─────────────┘  │  │  └─────────────┘  │    │
│  └───────────────────┘  └───────────────────┘  └───────────────────┘    │
│              │                     │                     │                │
│              └─────────────────────┼─────────────────────┘                │
│                                    │                                       │
│                              ┌─────┴─────┐                                │
│                              │ Shared    │                                │
│                              │ Services  │                                │
│                              └───────────┘                                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete Multi-Cloud Configuration

```nginx
# nginx-multi-cloud.conf - Complete Multi-Cloud Gateway
# ============================================================================
# NGINX MULTI-CLOUD GATEWAY
# Complete production-ready multi-cloud configuration
# ============================================================================

http {
    # =========================================================================
    # CLOUD PROVIDER MAPPING
    # =========================================================================
    # Detect cloud provider from metadata
    map $http_x_cloud_provider $cloud_provider {
        default "on-prem";
        "aws" "aws";
        "gcp" "gcp";
        "azure" "azure";
        "on-prem" "on-prem";
    }
    
    # Region mapping
    map $http_x_cloud_region $cloud_region {
        default "unknown";
        include /etc/nginx/cloud-regions.conf;
    }
    
    # =========================================================================
    # CLOUD-SPECIFIC UPSTREAMS
    # =========================================================================
    # AWS Backend
    upstream aws_backend {
        server aws-app1:8000 max_fails=3 fail_timeout=30s;
        server aws-app2:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # GCP Backend
    upstream gcp_backend {
        server gcp-app1:8000 max_fails=3 fail_timeout=30s;
        server gcp-app2:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Azure Backend
    upstream azure_backend {
        server azure-app1:8000 max_fails=3 fail_timeout=30s;
        server azure-app2:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # On-Prem Backend
    upstream on_prem_backend {
        server on-prem1:8000 max_fails=3 fail_timeout=30s;
        server on-prem2:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Multi-cloud failover group
    upstream multi_cloud_backend {
        # Primary: AWS
        server aws-app1:8000 weight=3 max_fails=3 fail_timeout=30s;
        server aws-app2:8000 weight=3 max_fails=3 fail_timeout=30s;
        
        # Secondary: GCP
        server gcp-app1:8000 weight=2 max_fails=3 fail_timeout=30s;
        server gcp-app2:8000 weight=2 max_fails=3 fail_timeout=30s;
        
        # Tertiary: Azure
        server azure-app1:8000 weight=1 max_fails=3 fail_timeout=30s;
        server azure-app2:8000 weight=1 max_fails=3 fail_timeout=30s;
        
        # Fallback: On-prem
        server on-prem1:8000 backup;
        server on-prem2:8000 backup;
        
        keepalive 64;
    }
    
    # =========================================================================
    # CLOUD-SPECIFIC HEADERS
    # =========================================================================
    # Cloud provider detection
    map $remote_addr $detected_cloud {
        default "unknown";
        "~^10\." "aws";  # AWS VPC
        "~^192\.168\." "gcp";  # GCP VPC
        "~^172\.16\." "azure";  # Azure VPC
    }
    
    # =========================================================================
    # CLOUD-SPECIFIC CACHING
    # =========================================================================
    proxy_cache_path /var/cache/nginx/cloud_cache
        levels=1:2
        keys_zone=cloud_cache:200m
        max_size=5g
        inactive=1h
        use_temp_path=off;
    
    # =========================================================================
    # MAIN MULTI-CLOUD SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name cloud.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/cloud.crt;
        ssl_certificate_key /etc/nginx/ssl/cloud.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1h;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        
        # Multi-cloud headers
        add_header X-Cloud-Provider $cloud_provider always;
        add_header X-Cloud-Region $cloud_region always;
        
        # =========================================================================
        # PRIMARY ROUTING
        # =========================================================================
        location / {
            # Route based on cloud provider
            if ($cloud_provider = "aws") {
                proxy_pass http://aws_backend/;
                set $current_cloud "aws";
            }
            if ($cloud_provider = "gcp") {
                proxy_pass http://gcp_backend/;
                set $current_cloud "gcp";
            }
            if ($cloud_provider = "azure") {
                proxy_pass http://azure_backend/;
                set $current_cloud "azure";
            }
            if ($cloud_provider = "on-prem") {
                proxy_pass http://on_prem_backend/;
                set $current_cloud "on-prem";
            }
            
            # Fallback to multi-cloud if provider unknown
            if ($current_cloud = "") {
                proxy_pass http://multi_cloud_backend/;
                set $current_cloud "multi-cloud";
            }
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Cloud-Provider $current_cloud;
            proxy_set_header X-Cloud-Region $cloud_region;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # =========================================================================
        # CLOUD-SPECIFIC ROUTING
        # =========================================================================
        location /aws/ {
            proxy_pass http://aws_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Cloud-Provider "aws";
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        location /gcp/ {
            proxy_pass http://gcp_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Cloud-Provider "gcp";
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        location /azure/ {
            proxy_pass http://azure_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Cloud-Provider "azure";
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # =========================================================================
        # FAILOVER ENDPOINT
        # =========================================================================
        location /failover/ {
            # Failover management
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            set $failover_target $arg_target;
            
            # Validate target
            if ($failover_target !~ ^(aws|gcp|azure|on-prem)$) {
                return 400 '{"error":"Invalid target"}';
                add_header Content-Type application/json;
            }
            
            # Update routing
            set $active_cloud $failover_target;
            
            return 200 '{"status":"failover initiated","target":"$failover_target"}';
            add_header Content-Type application/json;
        }
        
        # =========================================================================
        # CLOUD STATUS
        # =========================================================================
        location /cloud/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "active_cloud":"$active_cloud",
                "cloud_provider":"$cloud_provider",
                "cloud_region":"$cloud_region",
                "aws":$(curl -s -o /dev/null -w "%{http_code}" http://aws-app1:8000/health 2>/dev/null || echo "0"),
                "gcp":$(curl -s -o /dev/null -w "%{http_code}" http://gcp-app1:8000/health 2>/dev/null || echo "0"),
                "azure":$(curl -s -o /dev/null -w "%{http_code}" http://azure-app1:8000/health 2>/dev/null || echo "0"),
                "on-prem":$(curl -s -o /dev/null -w "%{http_code}" http://on-prem1:8000/health 2>/dev/null || echo "0"),
                "timestamp":"$time_iso8601"
            }';
            add_header Content-Type application/json;
        }
        
        # =========================================================================
        # HEALTH CHECK
        # =========================================================================
        location /health {
            access_log off;
            return 200 "healthy\n";
        }
    }
}
```

## P32.2 Hybrid Cloud Configuration

### Hybrid Cloud Gateway

```nginx
# nginx-hybrid.conf - Hybrid Cloud Gateway
# ============================================================================
# NGINX HYBRID CLOUD GATEWAY
# Complete hybrid cloud configuration
# ============================================================================

http {
    # =========================================================================
    # HYBRID UPSTREAMS
    # =========================================================================
    # Cloud Upstream
    upstream cloud_backend {
        server cloud-app1:8000 max_fails=3 fail_timeout=30s;
        server cloud-app2:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # On-Prem Upstream
    upstream on_prem_backend {
        server on-prem1:8000 max_fails=3 fail_timeout=30s;
        server on-prem2:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # Hybrid (combined)
    upstream hybrid_backend {
        # Cloud primary
        server cloud-app1:8000 weight=3 max_fails=3 fail_timeout=30s;
        server cloud-app2:8000 weight=3 max_fails=3 fail_timeout=30s;
        
        # On-prem secondary
        server on-prem1:8000 weight=1 max_fails=3 fail_timeout=30s;
        server on-prem2:8000 weight=1 max_fails=3 fail_timeout=30s;
        
        keepalive 64;
    }
    
    # =========================================================================
    # HYBRID ROUTING
    # =========================================================================
    map $cookie_routing_preference $hybrid_target {
        default "cloud";
        "cloud" "cloud";
        "on-prem" "on-prem";
        "hybrid" "hybrid";
    }
    
    # =========================================================================
    # HYBRID SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        server_name hybrid.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/hybrid.crt;
        ssl_certificate_key /etc/nginx/ssl/hybrid.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        
        # Hybrid headers
        add_header X-Hybrid-Gateway "nginx" always;
        add_header X-Routing-Preference $hybrid_target always;
        
        # =========================================================================
        # HYBRID ROUTING
        # =========================================================================
        location / {
            # Route based on preference
            if ($hybrid_target = "cloud") {
                proxy_pass http://cloud_backend/;
                set $target "cloud";
            }
            if ($hybrid_target = "on-prem") {
                proxy_pass http://on_prem_backend/;
                set $target "on-prem";
            }
            if ($hybrid_target = "hybrid") {
                proxy_pass http://hybrid_backend/;
                set $target "hybrid";
            }
            if ($hybrid_target = "") {
                proxy_pass http://hybrid_backend/;
                set $target "hybrid";
            }
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Routing-Preference $target;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
        }
        
        # =========================================================================
        # ROUTING PREFERENCE
        # =========================================================================
        location /routing/preference {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            # Set routing preference cookie
            add_header Set-Cookie "routing_preference=$arg_pref; Path=/; Max-Age=3600; HttpOnly";
            add_header X-Routing-Preference $arg_pref;
            
            return 200 '{"status":"updated","preference":"$arg_pref"}';
            add_header Content-Type application/json;
        }
        
        # =========================================================================
        # HYBRID STATUS
        # =========================================================================
        location /hybrid/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "routing_preference":"$hybrid_target",
                "cloud_health":$(curl -s -o /dev/null -w "%{http_code}" http://cloud-app1:8000/health 2>/dev/null || echo "0"),
                "on_prem_health":$(curl -s -o /dev/null -w "%{http_code}" http://on-prem1:8000/health 2>/dev/null || echo "0"),
                "requests_distribution":{
                    "cloud":$(tail -10000 /var/log/nginx/access.log | grep '"X-Routing-Preference":"cloud"' | wc -l),
                    "on-prem":$(tail -10000 /var/log/nginx/access.log | grep '"X-Routing-Preference":"on-prem"' | wc -l),
                    "hybrid":$(tail -10000 /var/log/nginx/access.log | grep '"X-Routing-Preference":"hybrid"' | wc -l)
                },
                "timestamp":"$time_iso8601"
            }';
            add_header Content-Type application/json;
        }
        
        # =========================================================================
        # HEALTH CHECK
        # =========================================================================
        location /health {
            access_log off;
            return 200 "healthy\n";
        }
    }
}
```

## P32.3 Multi-Cloud Monitoring

### Multi-Cloud Monitoring Dashboard

```bash
#!/bin/bash
# multi-cloud-monitor.sh - Multi-cloud monitoring

echo "=== Multi-Cloud Monitoring Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get cloud distribution
get_cloud_distribution() {
    echo "  Cloud Distribution:"
    tail -10000 /var/log/nginx/access.log | \
        grep -o '"X-Cloud-Provider":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | \
        while read count cloud; do
            echo "    $cloud: $count requests"
        done
}

# Function: Get cloud health
get_cloud_health() {
    echo "  Cloud Health:"
    for cloud in aws gcp azure on-prem; do
        health=$(curl -s -o /dev/null -w "%{http_code}" "http://${cloud}-app1:8000/health" 2>/dev/null)
        if [ "$health" = "200" ]; then
            echo -e "    ${GREEN}✓ $cloud: healthy${NC}"
        else
            echo -e "    ${RED}✗ $cloud: unhealthy (HTTP $health)${NC}"
        fi
    done
}

# Function: Get latency
get_latency() {
    echo "  Avg Latency by Cloud:"
    for cloud in aws gcp azure on-prem; do
        avg=$(tail -1000 /var/log/nginx/access.log | \
            grep "\"X-Cloud-Provider\":\"$cloud\"" | \
            grep -o '"request_time":[0-9.]*' | \
            cut -d':' -f2 | awk '{sum+=$1} END {if(NR>0) print sum/NR; else print "N/A"}')
        echo "    $cloud: ${avg}s"
    done
}

# Function: Get failover status
get_failover_status() {
    echo "  Failover Status:"
    local active=$(curl -s http://localhost/cloud/status 2>/dev/null | python -m json.tool | grep active_cloud | cut -d'"' -f4)
    echo "    Active Cloud: $active"
}

# Main display
while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              MULTI-CLOUD MONITORING DASHBOARD                 ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 CLOUD STATISTICS:"
    get_cloud_distribution
    echo ""
    get_cloud_health
    echo ""
    get_latency
    echo ""
    get_failover_status
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx for multi-cloud and hybrid cloud deployments. Use these techniques to build resilient, portable, and cost-optimized cloud architectures.
