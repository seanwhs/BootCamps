# Primer 31: Nginx for AI/ML Inference Gateways

## The Target

This primer provides a comprehensive deep-dive guide to using Nginx as an AI/ML inference gateway. Understanding these concepts is essential for building scalable, secure, and high-performance machine learning serving infrastructure.

## P31.1 AI/ML Inference Architecture

### ML Serving Stack

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    AI/ML INFERENCE ARCHITECTURE                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    NGINX ML INFERENCE GATEWAY                     │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    MODEL ROUTING                          │ │      │
│  │  │  • Model Selection    • Version Routing   • A/B Testing  │ │      │
│  │  │  • Canary Deployments • Model Registry    • Auto-scaling │ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    REQUEST PROCESSING                     │ │      │
│  │  │  • Request Batching  • Input Validation   • Preprocessing │ │      │
│  │  │  • Response Caching  • Output Filtering   • Postprocessing│ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  │  ┌────────────────────────────────────────────────────────────┐ │      │
│  │  │                    PERFORMANCE OPTIMIZATION               │ │      │
│  │  │  • Request Queuing   • Load Balancing    • GPU Scheduling │ │      │
│  │  │  • Model Caching     • Prediction Cache  • Dynamic Batching│ │      │
│  │  └────────────────────────────────────────────────────────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────────────────────────────────────────────────────────┐      │
│  │                    MODEL SERVING PLATFORMS                       │      │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐ │      │
│  │  │ TensorFlow │  │ PyTorch    │  │ ONNX       │  │ Triton   │ │      │
│  │  │ Serving    │  │ Serving    │  │ Runtime    │  │ Server   │ │      │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘ │      │
│  └──────────────────────────────────────────────────────────────────┘      │
│                                    │                                       │
│                                    ▼                                       │
│  ┌──────────────┬──────────────┬──────────────┬──────────────┐           │
│  │              │              │              │              │           │
│  ▼              ▼              ▼              ▼              ▼           │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐           │
│  │Model   │  │ Model  │  │ Model  │  │ Model  │  │ Model  │           │
│  │ v1     │  │ v2     │  │ v3     │  │ v4     │  │ v5     │           │
│  └────────┘  └────────┘  └────────┘  └────────┘  └────────┘           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Complete ML Inference Configuration

```nginx
# nginx-ml-inference.conf - Complete ML Inference Gateway
# ============================================================================
# NGINX AI/ML INFERENCE GATEWAY
# Complete production-ready ML inference configuration
# ============================================================================

http {
    # =========================================================================
    # ML SPECIFIC SETTINGS
    # =========================================================================
    # Large payloads for ML models
    client_max_body_size 50M;
    client_body_buffer_size 1M;
    client_header_buffer_size 4k;
    large_client_header_buffers 8 8k;
    
    # Long timeouts for inference
    client_body_timeout 60s;
    client_header_timeout 60s;
    send_timeout 60s;
    keepalive_timeout 60;
    keepalive_requests 1000;
    
    # =========================================================================
    # MODEL ROUTING
    # =========================================================================
    # Model version mapping
    map $http_x_model_version $model_version {
        default "latest";
        "v1" "v1";
        "v2" "v2";
        "v3" "v3";
        "v4" "v4";
        "v5" "v5";
        "latest" "latest";
    }
    
    # Model type routing
    map $http_x_model_type $model_upstream {
        default "default";
        "text" "text_models";
        "vision" "vision_models";
        "audio" "audio_models";
        "recommendation" "rec_models";
        "tabular" "tabular_models";
    }
    
    # Model endpoint routing
    map $request_uri $model_endpoint {
        default "/predict";
        "/predict" "/predict";
        "/explain" "/explain";
        "/embed" "/embed";
        "/batch" "/batch";
    }
    
    # =========================================================================
    # MODEL REGISTRY UPSTREAMS
    # =========================================================================
    upstream text_models {
        least_conn;
        server text-v1:8001 weight=3;
        server text-v2:8001 weight=1;
        keepalive 32;
    }
    
    upstream vision_models {
        least_conn;
        server vision-v1:8002 weight=3;
        server vision-v2:8002 weight=1;
        keepalive 32;
    }
    
    upstream audio_models {
        least_conn;
        server audio-v1:8003 weight=3;
        server audio-v2:8003 weight=1;
        keepalive 32;
    }
    
    upstream rec_models {
        least_conn;
        server rec-v1:8004 weight=3;
        server rec-v2:8004 weight=1;
        keepalive 32;
    }
    
    upstream tabular_models {
        least_conn;
        server tabular-v1:8005 weight=3;
        server tabular-v2:8005 weight=1;
        keepalive 32;
    }
    
    # =========================================================================
    # MODEL CACHING
    # =========================================================================
    proxy_cache_path /var/cache/nginx/prediction_cache
        levels=1:2
        keys_zone=prediction_cache:500m
        max_size=5g
        inactive=1h
        use_temp_path=off;
    
    proxy_cache_path /var/cache/nginx/embedding_cache
        levels=1:2
        keys_zone=embedding_cache:200m
        max_size=2g
        inactive=24h
        use_temp_path=off;
    
    # =========================================================================
    # RATE LIMITING
    # =========================================================================
    # Inference rate limiting by model type
    limit_req_zone $binary_remote_addr zone=text_infer:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=vision_infer:10m rate=5r/s;
    limit_req_zone $binary_remote_addr zone=audio_infer:10m rate=2r/s;
    limit_req_zone $binary_remote_addr zone=rec_infer:10m rate=20r/s;
    
    # API key tier mapping
    map $http_x_api_key $api_tier {
        default "free";
        "~^free_" "free";
        "~^basic_" "basic";
        "~^premium_" "premium";
        "~^enterprise_" "enterprise";
    }
    
    # Tier-based rate limits
    limit_req_zone $binary_remote_addr zone=free_infer:10m rate=1r/s;
    limit_req_zone $binary_remote_addr zone=basic_infer:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=premium_infer:10m rate=50r/s;
    limit_req_zone $binary_remote_addr zone=enterprise_infer:10m rate=200r/s;
    
    # =========================================================================
    # ML INFERENCE SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name ml.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/ml.crt;
        ssl_certificate_key /etc/nginx/ssl/ml.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 1h;
        
        # Security Headers
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "DENY" always;
        
        # ML specific headers
        add_header X-ML-Gateway "nginx" always;
        add_header X-ML-Version "2.0.0" always;
        
        # =========================================================================
        # PREDICTION ENDPOINT
        # =========================================================================
        location /predict {
            # API key validation
            if ($http_x_api_key = "") {
                return 401 '{"error":"API key required"}';
                add_header Content-Type application/json;
            }
            
            # Apply tier-based rate limiting
            if ($api_tier = "free") {
                limit_req zone=free_infer burst=2 nodelay;
            }
            if ($api_tier = "basic") {
                limit_req zone=basic_infer burst=10 nodelay;
            }
            if ($api_tier = "premium") {
                limit_req zone=premium_infer burst=50 nodelay;
            }
            if ($api_tier = "enterprise") {
                limit_req zone=enterprise_infer burst=200 nodelay;
            }
            
            # Model type rate limiting
            if ($model_upstream = "text_models") {
                limit_req zone=text_infer burst=10 nodelay;
            }
            if ($model_upstream = "vision_models") {
                limit_req zone=vision_infer burst=5 nodelay;
            }
            if ($model_upstream = "audio_models") {
                limit_req zone=audio_infer burst=2 nodelay;
            }
            if ($model_upstream = "rec_models") {
                limit_req zone=rec_infer burst=20 nodelay;
            }
            
            # Input validation
            if ($content_type !~ "application/json") {
                return 415 '{"error":"Content-Type must be application/json"}';
                add_header Content-Type application/json;
            }
            
            # Cache predictions
            proxy_cache prediction_cache;
            proxy_cache_key $scheme$host$request_uri$request_body$model_version;
            proxy_cache_valid 200 1m;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://$model_upstream$model_endpoint;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Model-Version $model_version;
            proxy_set_header X-Model-Type $model_upstream;
            proxy_set_header X-API-Key $http_x_api_key;
            proxy_set_header X-API-Tier $api_tier;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # BATCH INFERENCE
        # =========================================================================
        location /batch {
            if ($http_x_api_key = "") {
                return 401 '{"error":"API key required"}';
                add_header Content-Type application/json;
            }
            
            # Higher limits for batch
            if ($api_tier = "basic") {
                limit_req zone=basic_infer burst=20 nodelay;
            }
            if ($api_tier = "premium") {
                limit_req zone=premium_infer burst=100 nodelay;
            }
            if ($api_tier = "enterprise") {
                limit_req zone=enterprise_infer burst=500 nodelay;
            }
            
            # Large batch payloads
            client_max_body_size 100M;
            
            # Disable caching for batch
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
            
            proxy_pass http://$model_upstream/batch;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Model-Version $model_version;
            proxy_set_header X-Model-Type $model_upstream;
            proxy_set_header X-API-Key $http_x_api_key;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 10s;
            proxy_read_timeout 120s;
            proxy_send_timeout 120s;
            
            # Buffer for large responses
            proxy_buffering on;
            proxy_buffer_size 16k;
            proxy_buffers 16 16k;
            proxy_busy_buffers_size 32k;
        }
        
        # =========================================================================
        # EXPLAINABILITY ENDPOINT
        # =========================================================================
        location /explain {
            # Explainability features
            if ($http_x_api_key = "") {
                return 401 '{"error":"API key required"}';
                add_header Content-Type application/json;
            }
            
            # Stricter limits for explainability
            if ($api_tier = "free") {
                return 403 '{"error":"Explainability requires premium tier"}';
                add_header Content-Type application/json;
            }
            
            if ($api_tier = "premium") {
                limit_req zone=premium_infer burst=5 nodelay;
            }
            if ($api_tier = "enterprise") {
                limit_req zone=enterprise_infer burst=20 nodelay;
            }
            
            proxy_pass http://$model_upstream/explain;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Model-Version $model_version;
            proxy_set_header X-Model-Type $model_upstream;
            proxy_set_header X-API-Key $http_x_api_key;
            proxy_set_header X-API-Tier $api_tier;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 60s;
            proxy_send_timeout 60s;
            
            # No caching for explainability
            proxy_no_cache 1;
            proxy_cache_bypass 1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
        }
        
        # =========================================================================
        # EMBEDDING ENDPOINT
        # =========================================================================
        location /embed {
            # Generate embeddings
            if ($http_x_api_key = "") {
                return 401 '{"error":"API key required"}';
                add_header Content-Type application/json;
            }
            
            # Cache embeddings
            proxy_cache embedding_cache;
            proxy_cache_key $scheme$host$request_uri$request_body$model_version;
            proxy_cache_valid 200 24h;
            add_header X-Cache-Status $upstream_cache_status;
            
            proxy_pass http://$model_upstream/embed;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            proxy_set_header X-Model-Version $model_version;
            proxy_set_header X-Model-Type $model_upstream;
            proxy_set_header X-API-Key $http_x_api_key;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            proxy_connect_timeout 5s;
            proxy_read_timeout 30s;
            proxy_send_timeout 30s;
        }
        
        # =========================================================================
        # MODEL METADATA
        # =========================================================================
        location /models {
            # Model information endpoint
            proxy_pass http://model_registry/models;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            proxy_cache prediction_cache;
            proxy_cache_key $scheme$host$request_uri;
            proxy_cache_valid 200 1h;
            add_header X-Cache-Status $upstream_cache_status;
        }
        
        # =========================================================================
        # MODEL STATUS
        # =========================================================================
        location /models/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "models":{
                    "text":{
                        "versions":["v1","v2","latest"],
                        "active":true,
                        "load":$(docker stats --no-stream --format "{{.CPUPerc}}" text-v1 2>/dev/null | cut -d% -f1)
                    },
                    "vision":{
                        "versions":["v1","v2","latest"],
                        "active":true,
                        "load":$(docker stats --no-stream --format "{{.CPUPerc}}" vision-v1 2>/dev/null | cut -d% -f1)
                    },
                    "audio":{
                        "versions":["v1","latest"],
                        "active":true,
                        "load":$(docker stats --no-stream --format "{{.CPUPerc}}" audio-v1 2>/dev/null | cut -d% -f1)
                    },
                    "recommendation":{
                        "versions":["v1","v2","latest"],
                        "active":true,
                        "load":$(docker stats --no-stream --format "{{.CPUPerc}}" rec-v1 2>/dev/null | cut -d% -f1)
                    }
                },
                "gpu_utilization":$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1 || echo "0"),
                "requests":$(tail -10000 /var/log/nginx/access.log | wc -l),
                "cache_hit_rate":$(( $(tail -1000 /var/log/nginx/access.log | grep -c '"X-Cache-Status":"HIT"') * 100 / $(tail -1000 /var/log/nginx/access.log | wc -l) )),
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

## P31.2 Model Versioning & Canary

### Canary Deployment Configuration

```nginx
# nginx-model-canary.conf - Model Canary Deployment
# ============================================================================
# NGINX MODEL CANARY DEPLOYMENT
# Gradual rollout of new model versions
# ============================================================================

http {
    # =========================================================================
    # CANARY SPLIT
    # =========================================================================
    # Split traffic between model versions
    split_clients $remote_addr $model_split {
        95%   "stable";   # 95% to stable
        5%    "canary";   # 5% to canary
    }
    
    # Model version mapping
    map $model_split $model_target {
        stable "stable-model:8000";
        canary "canary-model:8001";
    }
    
    # =========================================================================
    # CANARY UPSTREAMS
    # =========================================================================
    upstream stable_models {
        server stable-model:8000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    upstream canary_models {
        server canary-model:8001 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }
    
    # =========================================================================
    # CANARY SERVER
    # =========================================================================
    server {
        listen 443 ssl http2;
        server_name ml.example.com;
        
        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/ml.crt;
        ssl_certificate_key /etc/nginx/ssl/ml.key;
        ssl_protocols TLSv1.2 TLSv1.3;
        
        # =========================================================================
        # CANARY PREDICTION
        # =========================================================================
        location /predict {
            # Route to appropriate model
            if ($model_split = "canary") {
                proxy_pass http://canary_models/predict;
                add_header X-Model-Version "canary";
            }
            if ($model_split = "stable") {
                proxy_pass http://stable_models/predict;
                add_header X-Model-Version "stable";
            }
            
            # Headers
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Request-ID $request_id;
            
            # Canary tracking
            proxy_set_header X-Canary-Split $model_split;
            
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # Log canary status
            access_log /var/log/nginx/canary.log;
        }
        
        # =========================================================================
        # CANARY STATUS
        # =========================================================================
        location /canary/status {
            allow 127.0.0.1;
            allow 10.0.0.0/8;
            deny all;
            
            return 200 '{
                "canary_percentage":5,
                "stable_requests":$(tail -10000 /var/log/nginx/access.log | grep '"X-Canary-Split":"stable"' | wc -l),
                "canary_requests":$(tail -10000 /var/log/nginx/access.log | grep '"X-Canary-Split":"canary"' | wc -l),
                "stable_error_rate":$(( $(tail -1000 /var/log/nginx/access.log | grep '"X-Canary-Split":"stable"' | grep -c '"status":5[0-9][0-9]') * 100 / $(tail -1000 /var/log/nginx/access.log | grep '"X-Canary-Split":"stable"' | wc -l) )),
                "canary_error_rate":$(( $(tail -1000 /var/log/nginx/access.log | grep '"X-Canary-Split":"canary"' | grep -c '"status":5[0-9][0-9]') * 100 / $(tail -1000 /var/log/nginx/access.log | grep '"X-Canary-Split":"canary"' | wc -l) )),
                "timestamp":"$time_iso8601"
            }';
            add_header Content-Type application/json;
        }
    }
}
```

## P31.3 ML Inference Monitoring

### ML Performance Dashboard

```bash
#!/bin/bash
# ml-inference-monitor.sh - ML inference monitoring

echo "=== ML Inference Monitoring Dashboard ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function: Get model performance
get_model_performance() {
    echo "  Model Performance:"
    tail -10000 /var/log/nginx/access.log | \
        grep -o '"X-Model-Type":"[^"]*"' | \
        cut -d'"' -f4 | sort | uniq -c | sort -nr | \
        while read count model; do
            echo "    $model: $count requests"
        done
}

# Function: Get inference latency
get_inference_latency() {
    local avg=$(tail -100 /var/log/nginx/access.log | \
        grep -o '"request_time":[0-9.]*' | \
        cut -d':' -f2 | awk '{sum+=$1} END {if(NR>0) print sum/NR; else print "N/A"}')
    echo "  Avg Inference Time: ${avg}s"
    
    local p95=$(tail -100 /var/log/nginx/access.log | \
        grep -o '"request_time":[0-9.]*' | \
        cut -d':' -f2 | sort -n | awk 'BEGIN{idx=0} {arr[idx++]=$1} END{print arr[int(idx*0.95)]}')
    echo "  P95 Inference Time: ${p95}s"
}

# Function: Get cache performance
get_cache_performance() {
    local hits=$(tail -1000 /var/log/nginx/access.log | grep -c '"X-Cache-Status":"HIT"')
    local total=$(tail -1000 /var/log/nginx/access.log | wc -l)
    if [ $total -gt 0 ]; then
        local rate=$((hits * 100 / total))
        echo "  Cache Hit Rate: $rate%"
    else
        echo "  Cache Hit Rate: N/A"
    fi
}

# Function: Get error rate
get_error_rate() {
    local errors=$(tail -1000 /var/log/nginx/access.log 2>/dev/null | grep -c '"status":5[0-9][0-9]')
    echo "  Error Rate: $errors%"
}

# Function: Get GPU utilization
get_gpu_utilization() {
    local gpu=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1 || echo "N/A")
    echo "  GPU Utilization: $gpu%"
}

# Main display
while true; do
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              ML INFERENCE MONITORING DASHBOARD                ║"
    echo "║                    $(date +"%Y-%m-%d %H:%M:%S")                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "📊 INFERENCE STATISTICS:"
    get_model_performance
    echo ""
    get_inference_latency
    echo ""
    get_cache_performance
    get_error_rate
    get_gpu_utilization
    echo ""
    
    echo "───────────────────────────────────────────────────────────────"
    sleep 5
done
```

---

This primer provides a comprehensive deep dive into using Nginx as an AI/ML inference gateway. Use these techniques to build scalable, secure, and high-performance machine learning serving infrastructure.
