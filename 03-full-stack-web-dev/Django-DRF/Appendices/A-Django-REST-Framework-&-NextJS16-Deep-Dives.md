# Appendix A: Django REST Framework & Next.js 16 Deep Dives

## Comprehensive Reference for Key Concepts

Welcome to **Appendix A** of the Django REST Framework & Next.js 16 masterclass. This appendix serves as a comprehensive reference for the deep conceptual dives referenced throughout the series. Use this as a reference when you need a deeper understanding of specific topics.

---

## Section 1: REST Architecture Deep Dive

### The Richardson Maturity Model

The Richardson Maturity Model describes the maturity levels of REST APIs:

```
Level 0: The Swamp of POX
├── Single URI for everything
├── Uses only POST
└── Example: XML-RPC, SOAP

Level 1: Resources
├── Multiple URIs for resources
├── Still uses only POST
└── Example: /api/createUser, /api/getUser

Level 2: HTTP Verbs
├── Uses proper HTTP methods
├── GET, POST, PUT, PATCH, DELETE
└── Example: GET /api/users/1/, POST /api/users/

Level 3: Hypermedia (HATEOAS)
├── Includes links in responses
├── Self-descriptive
└── Example: REST APIs with navigation links
```

### HATEOAS Explained

HATEOAS (Hypermedia as the Engine of Application State) means the API returns links to related resources:

```json
{
    "id": 1,
    "title": "Complete API Documentation",
    "status": "in_progress",
    "links": {
        "self": "/api/tasks/1/",
        "project": "/api/projects/5/",
        "comments": "/api/tasks/1/comments/",
        "update": {"method": "PATCH", "href": "/api/tasks/1/"},
        "delete": {"method": "DELETE", "href": "/api/tasks/1/"}
    }
}
```

**Benefits:**
- API becomes self-discoverable
- Clients don't need to construct URLs
- Changes to URL structure are transparent
- Reduces coupling between client and server

### REST vs GraphQL vs gRPC

| Aspect | REST | GraphQL | gRPC |
|--------|------|---------|------|
| **Data Fetching** | Multiple endpoints | Single endpoint, query language | Service definitions |
| **Over-fetching** | Common | Rare | Rare |
| **Under-fetching** | Common | Rare | Rare |
| **Caching** | Built-in (HTTP) | Requires setup | Not built-in |
| **Binary** | No | No | Yes |
| **Tooling** | Mature | Growing | Good |
| **Complexity** | Simple | Complex | Medium |
| **When to Use** | Most APIs | Complex data requirements | Microservices |

---

## Section 2: Django ORM Deep Dive

### QuerySet Evaluation Timing

QuerySets are **lazy** - they don't hit the database until evaluated:

```python
# No database query yet
tasks = Task.objects.all()

# Still no query
tasks = tasks.filter(status='todo')
tasks = tasks.order_by('-created_at')

# Database query executes here:
print(len(tasks))        # Evaluates
list(tasks)              # Evaluates
for task in tasks:       # Evaluates
    print(task.title)
bool(tasks)              # Evaluates
tasks[0]                 # Evaluates
```

### Query Optimization Patterns

#### Pattern 1: Nested Prefetching

```python
# Problem: Multiple levels of N+1 queries
projects = Project.objects.all()
for project in projects:
    for task in project.tasks.all():
        for comment in task.comments.all():
            print(comment)

# Solution: Prefetch all levels
projects = Project.objects.prefetch_related(
    'tasks__comments'  # Prefetch tasks and their comments
)

# Or with custom queryset
projects = Project.objects.prefetch_related(
    Prefetch('tasks', queryset=Task.objects.filter(status='active'))
)
```

#### Pattern 2: Subquery Optimization

```python
# Problem: Multiple queries for counts
tasks = Task.objects.all()
for task in tasks:
    comment_count = task.comments.count()  # N queries

# Solution 1: Annotate
tasks = Task.objects.annotate(
    comment_count=Count('comments')
)
for task in tasks:
    print(task.comment_count)  # No additional query

# Solution 2: Subquery
from django.db.models import Subquery, OuterRef

task_comments = Comment.objects.filter(task=OuterRef('id')).values('task_id')
tasks = Task.objects.annotate(
    comment_count=Subquery(task_comments.annotate(count=Count('id')).values('count'))
)
```

### Database Indexing Strategies

```python
# 1. Single column index
class Task(models.Model):
    class Meta:
        indexes = [
            models.Index(fields=['status']),
        ]

# 2. Composite index (for combined filters)
class Task(models.Model):
    class Meta:
        indexes = [
            models.Index(fields=['status', 'priority']),
        ]

# 3. Partial index (for filtered queries)
class Task(models.Model):
    class Meta:
        indexes = [
            models.Index(fields=['due_date'], condition=Q(status='todo')),
        ]

# 4. Functional index (for transformations)
class Task(models.Model):
    class Meta:
        indexes = [
            models.Index(fields=['due_date'], name='idx_task_duedate'),
        ]

# 5. Unique constraint index
class Task(models.Model):
    class Meta:
        unique_together = [['project', 'title']]
```

### When to Use Each ORM Feature

| Feature | Use Case | Example |
|---------|----------|---------|
| `select_related` | ForeignKey, OneToOne | `select_related('project')` |
| `prefetch_related` | ManyToMany, reverse FK | `prefetch_related('comments')` |
| `only()` | Limited fields | `only('id', 'title')` |
| `defer()` | Exclude heavy fields | `defer('description')` |
| `values()` | Dictionary output | `values('id', 'title')` |
| `values_list()` | Tuple output | `values_list('id', flat=True)` |
| `annotate()` | Add computed fields | `annotate(total=Sum('tasks'))` |
| `aggregate()` | Single summary | `aggregate(avg=Avg('priority'))` |

---

## Section 3: Django REST Framework Deep Dive

### Authentication Classes Comparison

| Class | Description | Best For |
|-------|-------------|----------|
| `BasicAuthentication` | HTTP Basic Auth | Simple, non-production APIs |
| `SessionAuthentication` | Django session | Browsable API, same-site apps |
| `TokenAuthentication` | DRF token auth | Simple API authentication |
| `JWTAuthentication` | JWT tokens | Modern APIs, mobile apps |
| `RemoteUserAuthentication` | External auth | SSO, enterprise apps |

### Custom Authentication

```python
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed

class APIKeyAuthentication(BaseAuthentication):
    def authenticate(self, request):
        api_key = request.headers.get('X-API-Key')
        if not api_key:
            return None
        
        try:
            client = Client.objects.get(api_key=api_key)
        except Client.DoesNotExist:
            raise AuthenticationFailed('Invalid API key')
        
        return (client.user, None)
```

### Permission Classes Deep Dive

```python
class CustomPermission(permissions.BasePermission):
    """
    Permission class with both view and object checks.
    """
    
    def has_permission(self, request, view):
        """
        Check at the view level.
        Called before has_object_permission.
        """
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # Only authenticated users can write
        return request.user and request.user.is_authenticated
    
    def has_object_permission(self, request, view, obj):
        """
        Check at the object level.
        Only called if has_permission returns True.
        """
        # Read-only for everyone
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # Check ownership
        if hasattr(obj, 'created_by'):
            return obj.created_by == request.user
        elif hasattr(obj, 'author'):
            return obj.author == request.user
        
        return False
```

### Generic Views Comparison

| View | Methods | Use Case |
|------|---------|----------|
| `ListAPIView` | GET | List resources |
| `CreateAPIView` | POST | Create resources |
| `RetrieveAPIView` | GET | Detail view |
| `UpdateAPIView` | PUT/PATCH | Update resources |
| `DestroyAPIView` | DELETE | Delete resources |
| `ListCreateAPIView` | GET, POST | List + Create |
| `RetrieveUpdateAPIView` | GET, PUT, PATCH | Read + Update |
| `RetrieveDestroyAPIView` | GET, DELETE | Read + Delete |
| `RetrieveUpdateDestroyAPIView` | GET, PUT, PATCH, DELETE | Full CRUD |

### ViewSet Actions

```python
class TaskViewSet(ModelViewSet):
    # Standard actions (automatic)
    # list()    - GET /tasks/
    # create()  - POST /tasks/
    # retrieve() - GET /tasks/{id}/
    # update()   - PUT /tasks/{id}/
    # partial_update() - PATCH /tasks/{id}/
    # destroy()  - DELETE /tasks/{id}/
    
    # Custom actions
    @action(detail=True, methods=['post'])
    def assign(self, request, pk=None):
        task = self.get_object()
        task.assigned_to = request.user
        task.save()
        return Response({'status': 'assigned'})
    
    @action(detail=False, methods=['get'])
    def stats(self, request):
        stats = {
            'total': Task.objects.count(),
            'completed': Task.objects.filter(status='done').count()
        }
        return Response(stats)
```

### Nested Serializer Patterns

```python
# Pattern 1: Read-only nested
class TaskSerializer(serializers.ModelSerializer):
    project = ProjectSerializer(read_only=True)
    
    class Meta:
        model = Task
        fields = ['id', 'title', 'project']

# Pattern 2: Write with IDs
class TaskSerializer(serializers.ModelSerializer):
    project_id = serializers.PrimaryKeyRelatedField(
        queryset=Project.objects.all(),
        source='project',
        write_only=True
    )
    
    class Meta:
        model = Task
        fields = ['id', 'title', 'project_id', 'project']

# Pattern 3: Create with nested
class TaskCreateSerializer(serializers.Serializer):
    title = serializers.CharField()
    project = ProjectSerializer()
    
    def create(self, validated_data):
        project_data = validated_data.pop('project')
        project, _ = Project.objects.get_or_create(**project_data)
        return Task.objects.create(project=project, **validated_data)
```

---

## Section 4: Next.js Deep Dive

### Server Components vs Client Components

**Server Components Characteristics:**

```tsx
// Server Component (default)
// ✅ Can use async/await
// ✅ Access server resources (DB, file system)
// ✅ Better performance (no client JS)
// ✅ SEO friendly
// ❌ No hooks (useState, useEffect)
// ❌ No browser APIs (window, document)
// ❌ No event handlers

export default async function ServerComponent() {
    const data = await fetchData();
    return <div>{data}</div>;
}
```

**Client Components Characteristics:**

```tsx
'use client';

// Client Component
// ✅ Can use hooks
// ✅ Browser APIs
// ✅ Interactive elements
// ❌ No async components (yet)
// ❌ More client JS
// ❌ No server-only features

export default function ClientComponent() {
    const [count, setCount] = useState(0);
    return <button onClick={() => setCount(c + 1)}>{count}</button>;
}
```

**When to Use:**

| Use Server Components For | Use Client Components For |
|---------------------------|---------------------------|
| Data fetching from APIs | Interactive UI elements |
| Static content | Forms and user input |
| SEO-critical pages | Real-time updates |
| Accessing databases | Client-side state |
| Reading env variables | Browser APIs (localStorage) |
| Large dependencies | Custom hooks |
| Metadata generation | Dynamic content updates |

### App Router Patterns

**Parallel Routes:**

```tsx
// app/dashboard/layout.tsx
export default function Layout({
    children,
    analytics,
    team,
}: {
    children: React.ReactNode;
    analytics: React.ReactNode;
    team: React.ReactNode;
}) {
    return (
        <div>
            {children}
            <div className="grid grid-cols-2">
                {analytics}
                {team}
            </div>
        </div>
    );
}
```

**Intercepting Routes:**

```tsx
// app/(.)photo/[id]/page.tsx - Intercepts /photo/[id]
// app/photos/[id]/page.tsx - Regular route
// Navigation from photos page shows modal
// Direct access shows full page
```

**Route Handlers:**

```tsx
// app/api/tasks/route.ts
export async function GET(request: Request) {
    const tasks = await prisma.task.findMany();
    return NextResponse.json(tasks);
}

export async function POST(request: Request) {
    const data = await request.json();
    const task = await prisma.task.create({ data });
    return NextResponse.json(task, { status: 201 });
}
```

### Data Fetching Patterns

**Pattern 1: Server Fetching:**

```tsx
// app/tasks/page.tsx
export default async function TasksPage() {
    const res = await fetch('http://localhost:8000/api/v1/tasks/', {
        cache: 'force-cache', // or 'no-store'
    });
    const data = await res.json();
    return <TaskList tasks={data} />;
}
```

**Pattern 2: Client Fetching:**

```tsx
'use client';

import { useEffect, useState } from 'react';

export function TaskList() {
    const [tasks, setTasks] = useState([]);
    const [loading, setLoading] = useState(true);
    
    useEffect(() => {
        fetch('/api/v1/tasks/')
            .then(res => res.json())
            .then(data => {
                setTasks(data);
                setLoading(false);
            });
    }, []);
    
    if (loading) return <Loading />;
    return <div>{/* Render tasks */}</div>;
}
```

**Pattern 3: Caching with SWR/React Query:**

```tsx
'use client';

import useSWR from 'swr';

export function TaskList() {
    const { data, error, isLoading } = useSWR('/api/v1/tasks/', fetcher);
    
    if (isLoading) return <Loading />;
    if (error) return <Error />;
    return <div>{/* Render tasks */}</div>;
}
```

### Middleware Patterns

```tsx
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
    const token = request.cookies.get('access_token');
    const isAuthenticated = !!token;
    
    // Redirect to login if not authenticated
    if (!isAuthenticated && request.nextUrl.pathname.startsWith('/dashboard')) {
        return NextResponse.redirect(new URL('/login', request.url));
    }
    
    // Redirect to dashboard if authenticated on auth pages
    if (isAuthenticated && ['/login', '/register'].includes(request.nextUrl.pathname)) {
        return NextResponse.redirect(new URL('/dashboard', request.url));
    }
    
    return NextResponse.next();
}
```

---

## Section 5: JWT Authentication Deep Dive

### JWT Structure

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

**Header:**
```json
{
    "alg": "HS256",
    "typ": "JWT"
}
```

**Payload (Claims):**
```json
{
    "sub": "1234567890",
    "name": "John Doe",
    "iat": 1516239022,
    "exp": 1516239322,
    "user_id": 1,
    "email": "john@example.com",
    "role": "admin"
}
```

**Signature:**
```
HMACSHA256(
    base64UrlEncode(header) + "." +
    base64UrlEncode(payload),
    secret
)
```

### Token Lifecycle Management

```python
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.token_blacklist.models import BlacklistedToken

def login_user(request):
    user = authenticate(email=email, password=password)
    if user:
        # Generate tokens
        refresh = RefreshToken.for_user(user)
        access = refresh.access_token
        
        # Store refresh token for rotation
        return {
            'access': str(access),
            'refresh': str(refresh),
            'user': user.serialize()
        }

def refresh_token(request):
    refresh_token = request.data.get('refresh')
    if not refresh_token:
        return error('Refresh token required')
    
    try:
        refresh = RefreshToken(refresh_token)
        
        # Check if token is blacklisted
        if BlacklistedToken.objects.filter(token=refresh).exists():
            return error('Token has been revoked')
        
        # Rotate refresh token
        new_refresh = RefreshToken.for_user(refresh.user)
        new_access = new_refresh.access_token
        
        # Blacklist old refresh token
        refresh.blacklist()
        
        return {
            'access': str(new_access),
            'refresh': str(new_refresh),
        }
    except TokenError:
        return error('Invalid refresh token')

def logout_user(request):
    refresh_token = request.data.get('refresh')
    if refresh_token:
        try:
            refresh = RefreshToken(refresh_token)
            refresh.blacklist()
        except TokenError:
            pass
    
    return {'status': 'logged out'}
```

### Token Security Best Practices

1. **Storage**:
   - Access Token: Memory or HTTP-only cookie
   - Refresh Token: HTTP-only cookie (most secure) or localStorage

2. **Expiration**:
   - Access Token: 15 minutes (short)
   - Refresh Token: 7 days (longer)

3. **Rotation**:
   - Issue new refresh token on each refresh
   - Blacklist old refresh tokens

4. **Revocation**:
   - Implement token blacklisting
   - Clear tokens on logout
   - Revoke tokens for security incidents

5. **Transport**:
   - Always use HTTPS
   - Use Bearer scheme
   - Include token in Authorization header

---

## Section 6: Docker Deep Dive

### Docker Image Optimization

**Layer Caching Strategy:**

```dockerfile
# 1. First, copy only package files (changes rarely)
COPY package.json package-lock.json ./
RUN npm install

# 2. Then, copy source code (changes frequently)
COPY . .

# 3. Build artifacts (depends on source)
RUN npm run build
```

**Image Size Reduction:**

```dockerfile
# Multi-stage build
FROM node:20 AS builder
# ... build steps ...

FROM node:20-slim
# ... only production dependencies ...

# Alpine base (smaller)
FROM python:3.12-slim

# Clean package manager caches
RUN apt-get update && apt-get install -y \
    package \
    && rm -rf /var/lib/apt/lists/*
```

### Docker Compose Advanced Patterns

**Health Checks:**

```yaml
services:
  backend:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    depends_on:
      db:
        condition: service_healthy
```

**Environment Variables:**

```yaml
services:
  backend:
    env_file:
      - .env
    environment:
      - DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@db:5432/${DB_NAME}
    secrets:
      - db_password
```

**Networks:**

```yaml
services:
  backend:
    networks:
      - internal
      - public

networks:
  internal:
    internal: true
  public:
    driver: bridge
```

### Production Deployment Checklist

- [ ] Use multi-stage builds
- [ ] Run as non-root user
- [ ] Set proper resource limits
- [ ] Configure health checks
- [ ] Use secrets for sensitive data
- [ ] Set restart policies
- [ ] Configure logging drivers
- [ ] Use image tags (not latest)
- [ ] Scan images for vulnerabilities
- [ ] Set up monitoring

---

## Section 7: Testing Deep Dive

### Pytest Fixture Patterns

```python
import pytest
from django.contrib.auth import get_user_model

@pytest.fixture
def user(db):
    return get_user_model().objects.create_user(
        email='test@example.com',
        password='testpass123'
    )

@pytest.fixture
def api_client():
    return APIClient()

@pytest.fixture
def auth_client(user, api_client):
    api_client.force_authenticate(user=user)
    return api_client

@pytest.fixture
def project(user):
    return Project.objects.create(
        name='Test Project',
        created_by=user
    )

@pytest.fixture
def task(user, project):
    return Task.objects.create(
        title='Test Task',
        project=project,
        created_by=user
    )
```

### Test Class Organization

```python
class TestTaskList:
    def test_unauthenticated_user_cannot_list_tasks(self, api_client):
        """Test that unauthenticated users get 401."""
        response = api_client.get(reverse('task-list'))
        assert response.status_code == 401
    
    def test_authenticated_user_can_list_tasks(self, auth_client):
        """Test that authenticated users can list tasks."""
        response = auth_client.get(reverse('task-list'))
        assert response.status_code == 200

class TestTaskDetail:
    def test_can_retrieve_task(self, auth_client, task):
        response = auth_client.get(reverse('task-detail', args=[task.id]))
        assert response.status_code == 200
    
    def test_cannot_retrieve_nonexistent_task(self, auth_client):
        response = auth_client.get(reverse('task-detail', args=[999]))
        assert response.status_code == 404
```

### Mocking API Calls

```python
from unittest.mock import patch, Mock

def test_external_api_call():
    with patch('requests.get') as mock_get:
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = {'data': 'test'}
        mock_get.return_value = mock_response
        
        result = call_external_api()
        assert result == {'data': 'test'}
        mock_get.assert_called_once()
```

---

## Section 8: Observability Deep Dive

### Prometheus Query Examples

```promql
# Request rate per second
rate(http_requests_total[5m])

# Error rate percentage
sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))

# 95th percentile response time
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Average response time
rate(http_request_duration_seconds_sum[5m]) / rate(http_request_duration_seconds_count[5m])

# Memory usage percentage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

### Sentry Integration Patterns

```python
import sentry_sdk
from sentry_sdk import capture_message, capture_exception

# Capture a message
sentry_sdk.capture_message('User logged in successfully')

# Capture an exception
try:
    risky_operation()
except Exception as e:
    sentry_sdk.capture_exception(e)
    raise

# Set user context
sentry_sdk.set_user({
    'id': user.id,
    'email': user.email,
})

# Set custom tags
sentry_sdk.set_tag('environment', 'production')
sentry_sdk.set_context('request', {
    'url': request.path,
    'method': request.method,
})
```

### Logging Best Practices

1. **Structured Logging**:
```python
import structlog

logger = structlog.get_logger()
logger.info('user_action', 
    user_id=user.id,
    action='login',
    ip=request.ip
)
```

2. **Log Levels**:
```python
logger.debug('Detailed debugging info')     # Development only
logger.info('Normal operation')             # Standard info
logger.warning('Something suspicious')      # Warning
logger.error('Something failed')            # Error
logger.critical('System failure')           # Critical
```

3. **Sensitive Data**:
```python
# Don't log sensitive data
logger.info('user_login', 
    user_id=user.id,  # OK
    # password=request.password,  # NEVER
    email=user.email  # Be careful
)

# Use redaction
def sanitize_log(data):
    if 'password' in data:
        data['password'] = '***'
    return data
```

---

## Quick Reference Cards

### Django ORM Quick Reference

```python
# Basic queries
Task.objects.all()                           # All tasks
Task.objects.filter(status='todo')           # Filter
Task.objects.exclude(status='done')          # Exclude
Task.objects.get(id=1)                       # Single

# Field lookups
Task.objects.filter(title__icontains='test') # Contains (case-insensitive)
Task.objects.filter(created_at__gt=now)      # Greater than
Task.objects.filter(created_at__lte=now)     # Less than or equal
Task.objects.filter(status__in=['todo','done']) # In list

# Aggregations
Task.objects.count()                         # Count
Task.objects.aggregate(Avg('priority'))      # Average
Task.objects.annotate(Count('comments'))     # Annotate

# Relationships
Task.objects.select_related('project')       # ForeignKey join
Task.objects.prefetch_related('comments')    # Many-to-many/reverse
```

### DRF Quick Reference

```python
# View types
@api_view(['GET', 'POST'])                   # Function-based
class MyView(APIView):                       # Class-based
class MyView(ListCreateAPIView):             # Generic view
class MyView(ModelViewSet):                  # ViewSet

# Serializer fields
CharField(max_length=100)                    # String
IntegerField()                               # Integer
BooleanField()                               # Boolean
DateField()                                  # Date
DateTimeField()                              # DateTime
EmailField()                                 # Email
URLField()                                   # URL
ForeignKey()                                 # ForeignKey
ManyToManyField()                            # ManyToMany

# Permissions
AllowAny                                     # Anyone
IsAuthenticated                              # Any authenticated user
IsAdminUser                                  # Admin only
IsAuthenticatedOrReadOnly                    # Read for all, write for auth

# Response shortcuts
Response(data, status=200)                   # JSON response
HttpResponse(content)                        # Raw response
JsonResponse(data)                           # JSON response
```

### Next.js Quick Reference

```tsx
// Page types
export default function Page()               // Server Component
'use client'                                 // Client Component
export async function generateMetadata()     // Metadata generation

// Data fetching (server)
fetch(url, { cache: 'force-cache' })        // Cache by default
fetch(url, { cache: 'no-store' })           // No caching
fetch(url, { next: { revalidate: 60 } })    // Revalidate every 60s

// Data fetching (client)
useEffect(() => fetchData(), [])             // Client-side fetch
useSWR('/api/data', fetcher)                // SWR
useQuery(['data'], fetchData)               // React Query

// Routing
/page.tsx -> /                               // Root
/about/page.tsx -> /about                    // Static
/[id]/page.tsx -> /123                      // Dynamic
/[...slug]/page.tsx -> /a/b/c               // Catch-all
/(group)/page.tsx -> /page                  // Route group

// Navigation
<Link href="/about">About</Link>            // Client navigation
router.push('/about')                        // Programmatic
router.replace('/about')                     // Replace history
router.refresh()                             // Refresh current
```

---

*This concludes Appendix A. Use these references as needed throughout your development journey.*
