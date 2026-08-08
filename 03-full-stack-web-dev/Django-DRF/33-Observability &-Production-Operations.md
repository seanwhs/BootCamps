# Part 33: Observability & Production Operations

## Monitoring, Logging, and Maintaining Your Production Application

Welcome to the **final part** of the Django REST Framework & Next.js 16 masterclass. In this concluding part, we'll implement comprehensive observability and production operations. We'll set up monitoring, logging, error tracking, and alerting to ensure we can see what's happening in production and respond quickly to issues.

In this part, we'll:
- Implement structured logging
- Set up application monitoring with Prometheus
- Add error tracking with Sentry
- Create dashboards for metrics visualization
- Set up alerting
- Implement health checks and readiness probes
- Create operational runbooks

Think of observability as your application's **vital signs monitor**. Just as a hospital monitors a patient's heart rate, blood pressure, and oxygen levels, observability gives you visibility into your application's health, performance, and behavior.

---

## The Target

We'll build a complete observability stack:

```
observability/
├── prometheus/
│   ├── prometheus.yml          # Prometheus configuration
│   └── rules.yml               # Alert rules
├── grafana/
│   ├── dashboards/
│   │   └── taskflow.json       # Dashboard configuration
│   └── datasources/
│       └── prometheus.yml      # Data source configuration
├── loki/
│   └── loki-config.yml         # Log aggregation
└── alerts/
    └── alertmanager.yml        # Alert configuration
```

---

## The Concept

### Observability Pillars

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Observability Pillars                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                     Logs                                    │   │
│  │  - Structured JSON logs                                    │   │
│  │  - Request/response logging                                │   │
│  │  - Error logs                                              │   │
│  │  - Audit logs                                              │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                     Metrics                                 │   │
│  │  - Request rate                                             │   │
│  │  - Error rate                                               │   │
│  │  - Response time                                            │   │
│  │  - System resources                                         │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                     Traces                                  │   │
│  │  - Request flow                                             │   │
│  │  - Service dependencies                                     │   │
│  │  - Performance bottlenecks                                  │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Metrics to Monitor

| Metric | What It Tells You | Alert Threshold |
|--------|-------------------|-----------------|
| **Request Rate** | How much traffic | Traffic spikes/drops |
| **Error Rate** | How many failures | > 5% over 5 minutes |
| **Response Time** | How fast responses are | P95 > 500ms |
| **CPU Usage** | Compute load | > 80% sustained |
| **Memory Usage** | Memory pressure | > 85% |
| **Database Connections** | DB load | > 80% pool |
| **Error Logs** | Application errors | Any new error type |

---

## The Implementation

### Step 1: Install Observability Dependencies

```bash
cd backend
source venv/bin/activate
pip install django-prometheus django-structlog sentry-sdk
pip install prometheus-client django-celery-beat
echo "django-prometheus>=2.3.0" >> requirements/base.txt
echo "django-structlog>=6.0.0" >> requirements/base.txt
echo "sentry-sdk>=1.40.0" >> requirements/base.txt
```

### Step 2: Configure Structured Logging

**backend/config/settings/production.py** (add logging)

```python
import structlog
import sentry_sdk
from sentry_sdk.integrations.django import DjangoIntegration
from sentry_sdk.integrations.redis import RedisIntegration

# Sentry configuration
SENTRY_DSN = env('SENTRY_DSN', default=None)
if SENTRY_DSN:
    sentry_sdk.init(
        dsn=SENTRY_DSN,
        integrations=[
            DjangoIntegration(),
            RedisIntegration(),
        ],
        traces_sample_rate=0.1,  # Sample 10% of transactions
        environment=env('DJANGO_ENV', 'production'),
        release='1.0.0',
    )

# Structured logging
structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt='iso'),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.UnicodeDecoder(),
        structlog.processors.JSONRenderer(),
    ],
    context_class=dict,
    logger_factory=structlog.stdlib.LoggerFactory(),
    cache_logger_on_first_use=True,
)

# Logging configuration
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'json': {
            '()': structlog.stdlib.ProcessorFormatter,
            'processor': structlog.processors.JSONRenderer(),
        },
    },
    'handlers': {
        'console': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
            'formatter': 'json',
        },
        'file': {
            'level': 'INFO',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': '/app/logs/app.log',
            'maxBytes': 10485760,
            'backupCount': 10,
            'formatter': 'json',
        },
        'sentry': {
            'level': 'ERROR',
            'class': 'sentry_sdk.integrations.logging.EventHandler',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console', 'file', 'sentry'],
            'level': 'INFO',
            'propagate': False,
        },
        'django.request': {
            'handlers': ['console', 'file', 'sentry'],
            'level': 'WARNING',
            'propagate': False,
        },
        'django.security': {
            'handlers': ['file', 'sentry'],
            'level': 'INFO',
            'propagate': False,
        },
        'api': {
            'handlers': ['console', 'file'],
            'level': 'INFO',
            'propagate': False,
        },
    },
}
```

### Step 3: Add Request Logging Middleware

**backend/apps/api/middleware.py** (add logging)

```python
import structlog
import time
import uuid
from django.utils.deprecation import MiddlewareMixin

logger = structlog.get_logger(__name__)


class StructuredLoggingMiddleware(MiddlewareMixin):
    """
    Middleware for structured request logging.
    """
    
    def process_request(self, request):
        # Generate request ID
        request_id = str(uuid.uuid4())
        request.request_id = request_id
        
        # Add request ID to logs
        structlog.contextvars.clear_contextvars()
        structlog.contextvars.bind_contextvars(
            request_id=request_id,
            method=request.method,
            path=request.path,
        )
        
        # Start timing
        request.start_time = time.time()
    
    def process_response(self, request, response):
        # Calculate duration
        duration = time.time() - request.start_time if hasattr(request, 'start_time') else 0
        
        # Log request
        logger.info(
            'request',
            method=request.method,
            path=request.path,
            status_code=response.status_code,
            duration=duration,
            user_id=getattr(request.user, 'id', None),
            ip=get_client_ip(request),
            user_agent=request.META.get('HTTP_USER_AGENT', ''),
        )
        
        return response


def get_client_ip(request):
    """Get client IP from request."""
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0]
    else:
        ip = request.META.get('REMOTE_ADDR')
    return ip
```

### Step 4: Add Prometheus Metrics

**backend/apps/api/metrics.py** (create)

```python
"""
Prometheus metrics for the API.
"""

from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST
from django.http import HttpResponse
import time

# Request metrics
REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

REQUEST_DURATION = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration in seconds',
    ['method', 'endpoint'],
    buckets=[0.01, 0.05, 0.1, 0.5, 1, 2.5, 5, 10]
)

# Database metrics
DB_QUERY_COUNT = Counter(
    'db_query_count_total',
    'Total database queries',
    ['model', 'operation']
)

DB_QUERY_DURATION = Histogram(
    'db_query_duration_seconds',
    'Database query duration in seconds',
    ['model', 'operation'],
    buckets=[0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1, 2]
)

# Cache metrics
CACHE_HIT_COUNT = Counter(
    'cache_hit_total',
    'Total cache hits',
    ['cache_name']
)

CACHE_MISS_COUNT = Counter(
    'cache_miss_total',
    'Total cache misses',
    ['cache_name']
)

# User metrics
ACTIVE_USERS = Gauge(
    'active_users',
    'Number of active users'
)

def metrics_view(request):
    """
    View to expose Prometheus metrics.
    """
    return HttpResponse(generate_latest(), content_type=CONTENT_TYPE_LATEST)
```

### Step 5: Update URLs for Metrics

**backend/config/urls.py** (add metrics endpoint)

```python
from apps.api.metrics import metrics_view

urlpatterns = [
    # ... other URLs ...
    path('metrics/', metrics_view, name='metrics'),
]
```

### Step 6: Configure Prometheus

**observability/prometheus/prometheus.yml** (create)

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'django'
    static_configs:
      - targets: ['backend:8000']
    metrics_path: '/metrics/'
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
        regex: '(.+):8000'
        replacement: '${1}'

  - job_name: 'postgres'
    static_configs:
      - targets: ['db:5432']
    metrics_path: '/metrics'
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
        regex: '(.+):5432'
        replacement: '${1}'

  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']
    metrics_path: '/metrics'
    relabel_configs:
      - source_labels: [__address__]
        target_label: instance
        regex: '(.+):6379'
        replacement: '${1}'

rule_files:
  - 'rules.yml'

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']
```

### Step 7: Create Alert Rules

**observability/prometheus/rules.yml** (create)

```yaml
groups:
  - name: api_alerts
    rules:
      - alert: HighErrorRate
        expr: 'rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.05'
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: 'High error rate on {{ $labels.instance }}'
          description: 'Error rate is {{ $value }}% on {{ $labels.instance }}'

      - alert: SlowResponseTime
        expr: 'histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 0.5'
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: 'Slow response time on {{ $labels.instance }}'
          description: 'P95 response time is {{ $value }}s on {{ $labels.instance }}'

      - alert: HighMemoryUsage
        expr: '(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85'
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: 'High memory usage on {{ $labels.instance }}'
          description: 'Memory usage is {{ $value }}% on {{ $labels.instance }}'

      - alert: HighCPUUsage
        expr: '100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80'
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: 'High CPU usage on {{ $labels.instance }}'
          description: 'CPU usage is {{ $value }}% on {{ $labels.instance }}'

      - alert: DatabaseConnectionPool
        expr: 'pg_stat_database_numbackends > 20'
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: 'Database connection pool nearly full'
          description: 'Connection count is {{ $value }} on {{ $labels.instance }}'
```

### Step 8: Configure Grafana

**observability/grafana/datasources/prometheus.yml** (create)

```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    jsonData:
      timeInterval: 15s
```

**observability/grafana/dashboards/taskflow.json** (create - simplified)

```json
{
  "title": "TaskFlow - API Dashboard",
  "uid": "taskflow-api",
  "tags": ["taskflow", "api"],
  "timezone": "browser",
  "schemaVersion": 16,
  "version": 1,
  "refresh": "30s",
  "panels": [
    {
      "title": "Request Rate",
      "type": "graph",
      "targets": [
        {
          "expr": "rate(http_requests_total[5m])",
          "legendFormat": "{{ method }} {{ endpoint }}"
        }
      ],
      "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
    },
    {
      "title": "Response Time (P95)",
      "type": "graph",
      "targets": [
        {
          "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
          "legendFormat": "{{ method }} {{ endpoint }}"
        }
      ],
      "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
    },
    {
      "title": "Error Rate",
      "type": "graph",
      "targets": [
        {
          "expr": "rate(http_requests_total{status=~\"5..\"}[5m]) / rate(http_requests_total[5m])",
          "legendFormat": "{{ endpoint }}"
        }
      ],
      "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8}
    },
    {
      "title": "Active Users",
      "type": "stat",
      "targets": [
        {
          "expr": "active_users"
        }
      ],
      "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8}
    }
  ]
}
```

### Step 9: Update Docker Compose for Observability

**docker-compose.prod.yml** (add observability services)

```yaml
services:
  # ... existing services ...

  prometheus:
    image: prom/prometheus:latest
    container_name: taskflow-prometheus
    volumes:
      - ./observability/prometheus:/etc/prometheus
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    networks:
      - taskflow-network
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: taskflow-grafana
    volumes:
      - ./observability/grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./observability/grafana/datasources:/etc/grafana/provisioning/datasources
      - grafana_data:/var/lib/grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD:-admin}
      - GF_INSTALL_PLUGINS=grafana-piechart-panel
    networks:
      - taskflow-network
    restart: unless-stopped
    depends_on:
      - prometheus

volumes:
  prometheus_data:
  grafana_data:
```

### Step 10: Create Runbook

**docs/runbooks/production-issues.md** (create)

```markdown
# Production Issue Runbook

## High Error Rate

### Symptoms
- Increased error responses (5xx)
- Users reporting issues
- Alert firing: "HighErrorRate"

### Investigation
1. Check logs for error patterns:
   ```bash
   docker-compose logs backend | grep ERROR
   ```

2. Check Sentry for new errors:
   - Go to Sentry dashboard
   - Look for new issues

3. Check database connections:
   ```bash
   docker-compose exec db psql -U taskflow_user -c "SELECT count(*) FROM pg_stat_activity;"
   ```

### Resolution
- If database issue: Restart database connections
- If code error: Rollback to previous version
- If external API issue: Check third-party status

### Post-Mortem
1. Document the issue
2. Add tests if needed
3. Update monitoring

## Slow Response Times

### Symptoms
- Users complaining about slow load times
- Alert firing: "SlowResponseTime"

### Investigation
1. Check current requests:
   ```bash
   docker-compose exec backend python manage.py shell -c "
   from django.db import connection
   print(connection.queries)
   "
   ```

2. Check database query performance:
   ```bash
   docker-compose exec db psql -U taskflow_user -c "SELECT * FROM pg_stat_statements ORDER BY total_time DESC LIMIT 10;"
   ```

3. Check resource usage:
   ```bash
   docker stats
   ```

### Resolution
- Scale up resources if needed
- Optimize slow queries
- Add caching

## Memory Leak

### Symptoms
- Memory usage increasing over time
- Alert firing: "HighMemoryUsage"

### Investigation
1. Check container memory:
   ```bash
   docker stats --no-stream
   ```

2. Check application memory:
   ```bash
   docker-compose exec backend python -c "
   import psutil
   print(psutil.Process().memory_info())
   "
   ```

3. Check for memory leaks:
   - Restart workers
   - Check for unreleased connections

### Resolution
- Restart the service
- Fix memory leak
- Increase memory limit
```

---

## The Verification

### Step 1: Start Services

```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Step 2: Check Prometheus

```bash
# Access Prometheus
open http://localhost:9090

# Check targets
# Should show all services as UP
```

### Step 3: Check Grafana

```bash
# Access Grafana
open http://localhost:3001

# Login (admin/admin)
# Should show TaskFlow dashboard
```

### Step 4: Check Logs

```bash
# View structured logs
docker-compose logs backend | jq '.'

# Filter errors
docker-compose logs backend | jq 'select(.level=="error")'
```

### Step 5: Test Alerts

```bash
# Simulate high error rate
for i in {1..100}; do
    curl -X GET http://localhost/api/v1/nonexistent
done

# Check Prometheus alerts
# Should show alert firing
```

---

## Key Takeaways

1. **Observability** provides visibility into application health and performance.

2. **Structured logging** makes logs searchable and analyzable.

3. **Metrics** provide quantitative data about application behavior.

4. **Alerts** notify the team of issues before users are affected.

5. **Dashboards** provide a visual overview of system health.

6. **Runbooks** provide step-by-step guides for common issues.

7. **Sentry** tracks and reports errors.

8. **Prometheus/Grafana** provide powerful monitoring and visualization.

---

## 🎉 Congratulations! You've Completed the Masterclass!

You've built a complete, production-ready application from scratch! Let's recap everything you've accomplished:

### Phase 1: REST API & Next.js Foundations
✅ REST architecture and HTTP fundamentals
✅ Django 6 backend with PostgreSQL
✅ DRF serializers and validation
✅ API views with CRUD operations
✅ Next.js 16 with App Router
✅ Complete data layer

### Phase 2: Advanced DRF Architecture & Next.js Data Flow
✅ Generic views, ViewSets, and Routers
✅ Advanced filtering with django-filter
✅ Pagination
✅ Next.js routing and navigation
✅ React Query for data fetching
✅ Searchable data interfaces

### Phase 3: Authentication, Authorization & Application Security
✅ JWT authentication with SimpleJWT
✅ Role-based access control
✅ Custom permissions
✅ Next.js authentication
✅ Request interception
✅ API security (rate limiting, CORS, headers)

### Phase 4: Performance, Testing, Documentation & Production
✅ Django ORM optimization
✅ Redis caching
✅ API performance optimization
✅ Automated testing (backend and frontend)
✅ OpenAPI documentation
✅ Docker containers for Django and Next.js
✅ Docker Compose orchestration
✅ Production configuration
✅ Reverse proxy with Nginx
✅ CI/CD pipeline
✅ Observability and monitoring

---

## What's Next?

1. **Deploy to the cloud**: AWS, GCP, or Azure
2. **Add more features**: Teams, file uploads, notifications
3. **Mobile app**: React Native or Flutter
4. **Performance tuning**: Continue optimizing
5. **Community**: Share and contribute to open source

---

**End of Part 33**
