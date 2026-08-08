# Primer 14: Nginx for High Availability & Disaster Recovery

## The Target

This primer provides a comprehensive deep-dive guide to building highly available Nginx deployments with robust disaster recovery capabilities. Understanding these concepts is essential for mission-critical production systems.

## P14.1 High Availability Architecture

### Multi-Region HA Design

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                    MULTI-REGION HIGH AVAILABILITY                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                         ┌─────────────────────┐                           │
│                         │   Global Load       │                           │
│                         │   Balancer (DNS)    │                           │
│                         └──────────┬──────────┘                           │
│                                    │                                       │
│              ┌─────────────────────┼─────────────────────┐                │
│              │                     │                     │                │
│              ▼                     ▼                     ▼                │
│  ┌───────────────────┐  ┌───────────────────┐  ┌───────────────────┐    │
│  │  Region US-East   │  │  Region EU-West   │  │  Region AP-East   │    │
│  │  ┌─────────────┐  │  │  ┌─────────────┐  │  │  ┌─────────────┐  │    │
│  │  │  Nginx HA   │  │  │  │  Nginx HA   │  │  │  │  Nginx HA   │  │    │
│  │  │  (Active)   │  │  │  │  (Active)   │  │  │  │  (Active)   │  │    │
│  │  └─────────────┘  │  │  └─────────────┘  │  │  └─────────────┘  │    │
│  │  ┌─────────────┐  │  │  ┌─────────────┐  │  │  ┌─────────────┐  │    │
│  │  │  Nginx HA   │  │  │  │  Nginx HA   │  │  │  │  Nginx HA   │  │    │
│  │  │  (Standby)  │  │  │  │  (Standby)  │  │  │  │  (Standby)  │  │    │
│  │  └─────────────┘  │  │  └─────────────┘  │  │  └─────────────┘  │    │
│  └───────────────────┘  └───────────────────┘  └───────────────────┘    │
│              │                     │                     │                │
│              └─────────────────────┼─────────────────────┘                │
│                                    │                                       │
│                              ┌─────┴─────┐                                │
│                              │ Backend   │                                │
│                              │ Services  │                                │
│                              └───────────┘                                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Active-Passive HA Configuration

```nginx
# nginx.conf - Active-Passive HA
http {
    # Health check endpoint for failover
    upstream backend {
        # Active server
        server active-backend:8000 max_fails=3 fail_timeout=30s;
        
        # Passive server (only used when active fails)
        server passive-backend:8000 backup;
        
        keepalive 32;
    }
    
    # Health monitoring
    location /health {
        proxy_pass http://backend/health;
        proxy_connect_timeout 2s;
        proxy_read_timeout 5s;
        access_log off;
    }
    
    location /api/ {
        # Failover configuration
        proxy_pass http://backend/;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
        proxy_next_upstream_tries 2;
        proxy_next_upstream_timeout 30s;
        
        # Connection draining
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        
        # Timeouts
        proxy_connect_timeout 5s;
        proxy_read_timeout 60s;
        proxy_send_timeout 60s;
        
        # Retry logic
        proxy_intercept_errors on;
        error_page 502 503 504 = @failover;
    }
    
    # Failover handler
    location @failover {
        return 503 '{"error":"Service temporarily unavailable"}';
        add_header Content-Type application/json;
        add_header Retry-After 30;
    }
}
```

### Active-Active HA Configuration

```nginx
# nginx.conf - Active-Active HA
http {
    upstream backend_cluster {
        # All instances active
        server backend1:8000 max_fails=3 fail_timeout=30s;
        server backend2:8000 max_fails=3 fail_timeout=30s;
        server backend3:8000 max_fails=3 fail_timeout=30s;
        
        # Health check
        keepalive 32;
        
        # Load balancing
        least_conn;  # Send to least busy server
    }
    
    # Session stickiness (if needed)
    map $cookie_sessionid $backend_server {
        default "";
        ~^([a-f0-9]+) backend$1:8000;
    }
    
    location /api/ {
        # Sticky sessions using cookie
        proxy_pass http://backend_cluster/;
        
        # Stickiness with cookie
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Session persistence
        proxy_cookie_path / "/; Secure; HttpOnly";
    }
}
```

## P14.2 Disaster Recovery

### Backup and Restore Strategy

```bash
#!/bin/bash
# disaster-recovery.sh - Complete DR script

set -e

echo "=== Disaster Recovery Management ==="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

BACKUP_DIR="/backups/nginx"
RETENTION_DAYS=30

# Function: Full backup
full_backup() {
    echo -e "${BLUE}Performing full backup...${NC}"
    
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_PATH="$BACKUP_DIR/full_$TIMESTAMP"
    mkdir -p "$BACKUP_PATH"
    
    # Backup configuration
    cp -r /etc/nginx "$BACKUP_PATH/nginx.conf.d"
    
    # Backup SSL certificates
    cp -r /etc/nginx/ssl "$BACKUP_PATH/ssl"
    
    # Backup custom files
    cp -r /var/www/html "$BACKUP_PATH/html" 2>/dev/null || true
    
    # Backup cache (optional)
    # tar -czf "$BACKUP_PATH/cache.tar.gz" /var/cache/nginx 2>/dev/null || true
    
    # Backup logs (optional)
    # tar -czf "$BACKUP_PATH/logs.tar.gz" /var/log/nginx 2>/dev/null || true
    
    # Create archive
    tar -czf "$BACKUP_DIR/full_$TIMESTAMP.tar.gz" -C "$BACKUP_PATH" .
    rm -rf "$BACKUP_PATH"
    
    echo -e "${GREEN}✓ Full backup created: full_$TIMESTAMP.tar.gz${NC}"
}

# Function: Incremental backup
incremental_backup() {
    echo -e "${BLUE}Performing incremental backup...${NC}"
    
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_PATH="$BACKUP_DIR/inc_$TIMESTAMP"
    mkdir -p "$BACKUP_PATH"
    
    # Backup only changed files
    find /etc/nginx -type f -mtime -1 -exec cp --parents {} "$BACKUP_PATH" \; 2>/dev/null || true
    find /etc/nginx/ssl -type f -mtime -1 -exec cp --parents {} "$BACKUP_PATH" \; 2>/dev/null || true
    
    # Create archive
    if [ "$(ls -A $BACKUP_PATH)" ]; then
        tar -czf "$BACKUP_DIR/inc_$TIMESTAMP.tar.gz" -C "$BACKUP_PATH" .
        echo -e "${GREEN}✓ Incremental backup created: inc_$TIMESTAMP.tar.gz${NC}"
    else
        echo -e "${YELLOW}⚠ No changes detected${NC}"
        rm -rf "$BACKUP_PATH"
    fi
}

# Function: Restore from backup
restore_backup() {
    local backup_file=$1
    
    if [ -z "$backup_file" ]; then
        echo "Usage: $0 restore <backup_file.tar.gz>"
        exit 1
    fi
    
    echo -e "${BLUE}Restoring from backup: $backup_file${NC}"
    
    RESTORE_DIR="/tmp/nginx_restore"
    mkdir -p "$RESTORE_DIR"
    
    # Extract backup
    tar -xzf "$BACKUP_DIR/$backup_file" -C "$RESTORE_DIR"
    
    # Backup current configuration
    cp -r /etc/nginx "/etc/nginx.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Restore configuration
    if [ -d "$RESTORE_DIR/etc/nginx" ]; then
        cp -r "$RESTORE_DIR/etc/nginx"/* /etc/nginx/
    fi
    
    # Restore SSL certificates
    if [ -d "$RESTORE_DIR/ssl" ]; then
        cp -r "$RESTORE_DIR/ssl"/* /etc/nginx/ssl/
    fi
    
    # Restore HTML files
    if [ -d "$RESTORE_DIR/html" ]; then
        cp -r "$RESTORE_DIR/html"/* /var/www/html/
    fi
    
    # Test configuration
    nginx -t
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Configuration test failed!${NC}"
        echo "Restoring previous configuration..."
        cp -r "/etc/nginx.backup."*/* /etc/nginx/
        exit 1
    fi
    
    # Reload Nginx
    nginx -s reload
    
    rm -rf "$RESTORE_DIR"
    
    echo -e "${GREEN}✓ Restore complete!${NC}"
}

# Function: Cleanup old backups
cleanup_backups() {
    echo -e "${BLUE}Cleaning up backups older than $RETENTION_DAYS days...${NC}"
    
    find "$BACKUP_DIR" -name "*.tar.gz" -type f -mtime +$RETENTION_DAYS -delete
    
    echo -e "${GREEN}✓ Cleanup complete${NC}"
}

# Function: Verify backup integrity
verify_backup() {
    local backup_file=$1
    
    echo -e "${BLUE}Verifying backup: $backup_file${NC}"
    
    if tar -tzf "$BACKUP_DIR/$backup_file" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Backup is valid${NC}"
        return 0
    else
        echo -e "${RED}✗ Backup is corrupted${NC}"
        return 1
    fi
}

# Command handler
case "$1" in
    backup)
        if [ "$2" = "full" ]; then
            full_backup
        elif [ "$2" = "inc" ]; then
            incremental_backup
        else
            echo "Usage: $0 backup [full|inc]"
            exit 1
        fi
        ;;
    restore)
        restore_backup "$2"
        ;;
    verify)
        verify_backup "$2"
        ;;
    cleanup)
        cleanup_backups
        ;;
    *)
        echo "Usage: $0 {backup full|backup inc|restore <file>|verify <file>|cleanup}"
        echo ""
        echo "Commands:"
        echo "  backup full  - Create full backup"
        echo "  backup inc   - Create incremental backup"
        echo "  restore      - Restore from backup"
        echo "  verify       - Verify backup integrity"
        echo "  cleanup      - Remove old backups"
        exit 1
        ;;
esac
```

### Cross-Region Replication

```yaml
# cross-region-replication.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-replication
  namespace: production
data:
  replication.yaml: |
    # Multi-region Nginx configuration
    upstream global_backend {
      # Primary region
      server primary-backend:8000 max_fails=3 fail_timeout=30s;
      
      # Secondary region (for failover)
      server secondary-backend:8000 max_fails=3 fail_timeout=30s backup;
      
      keepalive 32;
    }
    
    server {
      listen 443 ssl http2;
      server_name example.com;
      
      location / {
        # Geo-based routing
        if ($geoip_country_code = "US") {
          proxy_pass http://us-backend/;
        }
        if ($geoip_country_code = "DE") {
          proxy_pass http://eu-backend/;
        }
        if ($geoip_country_code = "JP") {
          proxy_pass http://ap-backend/;
        }
        
        # Fallback to global
        proxy_pass http://global_backend/;
      }
    }
```

## P14.3 Health Checks & Monitoring

### Advanced Health Checks

```nginx
# nginx.conf - Advanced health checks
http {
    # Health check endpoint
    location /health {
        access_log off;
        
        # Check multiple services
        set $health_status "healthy";
        
        # Check upstream
        if ($upstream_addr = "") {
            set $health_status "unhealthy";
        }
        
        # Check cache
        if ($http_x_cache_status = "MISS") {
            set $health_status "degraded";
        }
        
        # Return health status
        if ($health_status = "healthy") {
            return 200 '{"status":"healthy","timestamp":"$time_iso8601"}';
        }
        if ($health_status = "degraded") {
            return 200 '{"status":"degraded","timestamp":"$time_iso8601"}';
        }
        return 503 '{"status":"unhealthy","timestamp":"$time_iso8601"}';
        
        add_header Content-Type application/json;
    }
    
    # Detailed health check
    location /health/detailed {
        access_log off;
        
        # Check all components
        set $health_details "";
        
        # Check Nginx
        if ($status = 200) {
            set $health_details "${health_details}nginx:ok;";
        }
        
        # Check upstream
        if ($upstream_status = 200) {
            set $health_details "${health_details}upstream:ok;";
        }
        
        # Check cache
        if ($upstream_cache_status = "HIT") {
            set $health_details "${health_details}cache:hit;";
        } else {
            set $health_details "${health_details}cache:miss;";
        }
        
        return 200 '{"status":"ok","details":"$health_details","timestamp":"$time_iso8601"}';
        add_header Content-Type application/json;
    }
}
```

### Health Check Script

**File: `health-check-monitor.sh`**

```bash
#!/bin/bash
# health-check-monitor.sh - Continuous health monitoring

echo "=== Health Monitor Started ==="

while true; do
    TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
    
    # Check Nginx
    NGINX_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/health 2>/dev/null)
    
    # Check upstream
    UPSTREAM_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/api/health 2>/dev/null)
    
    # Check WebSocket
    WS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Connection: Upgrade" \
        -H "Upgrade: websocket" \
        http://localhost/ws/ 2>/dev/null)
    
    # Check SSE
    SSE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Accept: text/event-stream" \
        http://localhost/sse/ 2>/dev/null)
    
    # Log results
    echo "[$TIMESTAMP] Nginx: $NGINX_STATUS | Upstream: $UPSTREAM_STATUS | WS: $WS_STATUS | SSE: $SSE_STATUS"
    
    # Alert if unhealthy
    if [ "$NGINX_STATUS" != "200" ] || [ "$UPSTREAM_STATUS" != "200" ]; then
        echo "⚠️  ALERT: Service unhealthy at $TIMESTAMP"
        # Send alert (email, Slack, PagerDuty)
    fi
    
    sleep 10
done
```

## P14.4 Failover Automation

### Automatic Failover Script

```bash
#!/bin/bash
# failover.sh - Automatic failover

set -e

echo "=== Failover Controller ==="

# Configuration
PRIMARY_HOST="primary-backend:8000"
SECONDARY_HOST="secondary-backend:8000"
HEALTH_CHECK_INTERVAL=10
FAILOVER_THRESHOLD=3

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function: Check service health
check_health() {
    local host=$1
    curl -s -o /dev/null -w "%{http_code}" "http://$host/health" 2>/dev/null
}

# Function: Perform failover
perform_failover() {
    echo -e "${RED}⚠️  Performing failover...${NC}"
    
    # Update Nginx configuration
    sed -i "s/server $PRIMARY_HOST/server $PRIMARY_HOST backup/g" /etc/nginx/conf.d/upstream.conf
    sed -i "s/server $SECONDARY_HOST backup/server $SECONDARY_HOST/g" /etc/nginx/conf.d/upstream.conf
    
    # Test configuration
    nginx -t
    if [ $? -eq 0 ]; then
        nginx -s reload
        echo -e "${GREEN}✓ Failover complete${NC}"
        echo "Failover to $SECONDARY_HOST at $(date)" >> /var/log/failover.log
    else
        echo -e "${RED}✗ Failover failed!${NC}"
        exit 1
    fi
}

# Function: Perform failback
perform_failback() {
    echo -e "${GREEN}▶ Performing failback...${NC}"
    
    # Restore original configuration
    sed -i "s/server $PRIMARY_HOST backup/server $PRIMARY_HOST/g" /etc/nginx/conf.d/upstream.conf
    sed -i "s/server $SECONDARY_HOST/server $SECONDARY_HOST backup/g" /etc/nginx/conf.d/upstream.conf
    
    # Test configuration
    nginx -t
    if [ $? -eq 0 ]; then
        nginx -s reload
        echo -e "${GREEN}✓ Failback complete${NC}"
        echo "Failback to $PRIMARY_HOST at $(date)" >> /var/log/failover.log
    else
        echo -e "${RED}✗ Failback failed!${NC}"
        exit 1
    fi
}

# Main loop
failover_count=0
current_primary="primary"

while true; do
    if [ "$current_primary" = "primary" ]; then
        status=$(check_health $PRIMARY_HOST)
        if [ "$status" != "200" ]; then
            failover_count=$((failover_count + 1))
            echo "Primary health check failed ($failover_count/$FAILOVER_THRESHOLD)"
            
            if [ $failover_count -ge $FAILOVER_THRESHOLD ]; then
                perform_failover
                current_primary="secondary"
                failover_count=0
            fi
        else
            failover_count=0
        fi
    else
        # Check if primary is back
        status=$(check_health $PRIMARY_HOST)
        if [ "$status" = "200" ]; then
            # Primary is healthy, perform failback
            perform_failback
            current_primary="primary"
        fi
    fi
    
    sleep $HEALTH_CHECK_INTERVAL
done
```

### Kubernetes Liveness & Readiness Probes

```yaml
# kubernetes/nginx-probes.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-proxy
  namespace: production
spec:
  template:
    spec:
      containers:
      - name: nginx
        image: nginx:1.27-alpine
        ports:
        - containerPort: 80
        - containerPort: 443
        # Liveness Probe - restart if unhealthy
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 3
        # Readiness Probe - stop traffic if unhealthy
        readinessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 2
        # Startup Probe - wait for initial startup
        startupProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 30
```

## P14.5 Disaster Recovery Runbook

### Complete DR Runbook

```markdown
# Disaster Recovery Runbook

## 1. Preparation

### 1.1 Backup Locations
- Configuration: `/backups/nginx/`
- SSL Certificates: `/backups/nginx/ssl/`
- Custom Files: `/backups/nginx/html/`
- Cache: `/backups/nginx/cache/` (optional)
- Logs: `/backups/nginx/logs/` (optional)

### 1.2 Recovery Team Contacts
- Primary: [Name] [Phone] [Email]
- Secondary: [Name] [Phone] [Email]
- Vendor Support: [Contact]

### 1.3 Recovery Tools
- `disaster-recovery.sh` script
- `failover.sh` script
- `health-check-monitor.sh` script
- Docker/Kubernetes tools
- Terraform/Ansible tools

## 2. Incident Detection

### 2.1 Monitoring Alerts
- High error rate (>5%)
- High response time (>1s)
- Service down (health check fails)
- Certificate expiry (<30 days)
- Resource exhaustion

### 2.2 Manual Detection
- User reports
- Monitoring dashboard
- Log analysis
- Performance degradation

## 3. Initial Response

### 3.1 Assessment (0-5 minutes)
1. Check monitoring dashboard
2. Verify service status
3. Determine scope (partial/full)
4. Identify affected components

### 3.2 Communication (5-10 minutes)
1. Notify team
2. Update status page
3. Inform stakeholders
4. Escalate if needed

## 4. Recovery Procedures

### 4.1 Single Instance Failure (10-30 minutes)
1. Check health: `./health-check-monitor.sh`
2. Restart instance: `docker restart nginx`
3. Verify recovery: `curl http://localhost/health`

### 4.2 Full Service Failure (30-60 minutes)
1. Check logs: `tail -100 /var/log/nginx/error.log`
2. Restore from backup: `./disaster-recovery.sh restore <backup-file>`
3. Verify configuration: `nginx -t`
4. Reload Nginx: `nginx -s reload`
5. Verify service: `./health-check.sh`

### 4.3 Infrastructure Failure (1-2 hours)
1. Deploy to secondary region
2. Update DNS records
3. Verify traffic flow
4. Monitor recovery

### 4.4 Data Corruption (2-4 hours)
1. Stop Nginx: `nginx -s stop`
2. Restore from full backup
3. Verify data integrity
4. Start Nginx: `nginx`
5. Verify service

## 5. Post-Recovery

### 5.1 Validation (30 minutes)
1. Run full health check
2. Verify all endpoints
3. Check performance metrics
4. Review error logs

### 5.2 Documentation (1 hour)
1. Document root cause
2. Record recovery steps
3. Update runbook
4. Create Jira/issue

### 5.3 Prevention (2-4 hours)
1. Fix root cause
2. Update monitoring
3. Improve automation
4. Schedule follow-up

## 6. Recovery Time Objectives

| Scenario | RTO | RPO |
|----------|-----|-----|
| Single instance | 15 min | 0 min |
| Full service | 60 min | 5 min |
| Infrastructure | 2 hours | 10 min |
| Data corruption | 4 hours | 30 min |
| Catastrophic | 8 hours | 1 hour |

## 7. Escalation Procedure

| Level | Contact | Response Time |
|-------|---------|---------------|
| Level 1 | On-call engineer | 5 min |
| Level 2 | Team lead | 15 min |
| Level 3 | Infrastructure manager | 30 min |
| Level 4 | CTO/VP | 1 hour |

## 8. Testing Schedule

| Test Type | Frequency | Duration |
|-----------|-----------|----------|
| DR Drill | Quarterly | 4 hours |
| Backup Restore | Monthly | 1 hour |
| Failover Test | Monthly | 30 min |
| Performance Test | Weekly | 2 hours |
| Security Audit | Quarterly | 8 hours |

## 9. Tools & Resources

### 9.1 Recovery Scripts
```bash
# List available backups
ls -la /backups/nginx/*.tar.gz

# Verify backup
./disaster-recovery.sh verify <backup-file>

# Restore backup
./disaster-recovery.sh restore <backup-file>

# Check health
./health-check.sh

# Monitor service
./health-check-monitor.sh
```

### 9.2 Docker Commands
```bash
# Start service
docker compose up -d nginx

# Stop service
docker compose down nginx

# Restart service
docker compose restart nginx

# Check logs
docker logs nginx --tail 50 -f
```

### 9.3 Kubernetes Commands
```bash
# Check deployment
kubectl get pods -n production -l app=nginx

# Check logs
kubectl logs -n production deployment/nginx --tail 50 -f

# Restart deployment
kubectl rollout restart deployment/nginx -n production

# Rollback deployment
kubectl rollout undo deployment/nginx -n production
```

## 10. Lessons Learned

### 10.1 Common Failure Modes
- SSL certificate expiry
- Disk space exhaustion
- Memory exhaustion
- Network partition
- Upstream service crash
- Configuration error

### 10.2 Improvement Areas
- Monitoring coverage
- Alert sensitivity
- Recovery automation
- Documentation quality
- Testing frequency
```

---

This primer provides a comprehensive deep dive into building high availability and disaster recovery capabilities for Nginx. Use these techniques to ensure your production systems remain available even during failures.
