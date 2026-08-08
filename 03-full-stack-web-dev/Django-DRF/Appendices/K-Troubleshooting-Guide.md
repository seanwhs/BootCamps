# Appendix K: Troubleshooting Guide

## Complete Troubleshooting Reference

Welcome to **Appendix K** of the Django REST Framework & Next.js 16 masterclass. This appendix provides a comprehensive troubleshooting guide for common issues encountered throughout the development journey.

---

## Section 1: Backend Troubleshooting

### 1.1 Django Issues

**Issue: "django.core.exceptions.ImproperlyConfigured"**

```bash
# Common causes:
# - Missing environment variables
# - Incorrect settings module

# Solution:
# Check environment variables
echo $DJANGO_SETTINGS_MODULE
export DJANGO_SETTINGS_MODULE=config.settings

# Check .env file
cat backend/.env

# Verify SECRET_KEY is set
python -c "import os; print(os.environ.get('SECRET_KEY'))"
```

**Issue: "django.db.utils.OperationalError: could not connect to server"**

```bash
# Database connection issues

# Check if PostgreSQL is running
sudo systemctl status postgresql  # Linux
brew services list | grep postgres  # macOS
docker ps | grep postgres  # Docker

# Check connection settings
# Verify DATABASE_URL in .env
DATABASE_URL=postgresql://user:password@host:port/dbname

# Test connection
psql -U username -h hostname -d dbname

# Restart PostgreSQL
sudo systemctl restart postgresql  # Linux
brew services restart postgresql  # macOS
docker-compose restart db  # Docker
```

**Issue: "django.db.migrations.exceptions.InconsistentMigrationHistory"**

```bash
# Migration conflicts

# Check migration status
python manage.py showmigrations

# Fake migrations (only if you know what you're doing)
python manage.py migrate --fake

# Reset migrations (careful - data loss)
python manage.py migrate app_name zero
python manage.py migrate app_name

# For development, you can reset database
python manage.py reset_db  # Requires django-extensions
python manage.py migrate
```

**Issue: "ModuleNotFoundError: No module named 'apps'"**

```bash
# Python path issues

# Check PYTHONPATH
echo $PYTHONPATH

# Add project root to path
export PYTHONPATH="${PYTHONPATH}:/path/to/project"

# Or run from correct directory
cd /path/to/project/backend
python manage.py runserver

# Check if __init__.py files exist
find . -name "__init__.py"
```

**Issue: "django.contrib.auth.models.User" vs custom User model**

```python
# If you get this error after changing User model:
# "AUTH_USER_MODEL refers to model 'users.User' that has not been installed"

# Solution:
# 1. Delete migrations
rm -rf apps/users/migrations/*.py
rm -rf apps/users/migrations/__pycache__/

# 2. Make migrations
python manage.py makemigrations users

# 3. Migrate
python manage.py migrate

# 4. Create superuser
python manage.py createsuperuser
```

### 1.2 DRF Issues

**Issue: "PermissionDenied: You do not have permission to perform this action"**

```python
# Check view permissions
class MyViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]  # Make sure this is set
    
# Check user authentication
def get_permissions(self):
    if self.action == 'list':
        return [AllowAny()]
    return [IsAuthenticated()]

# Check user has required role
if user.role not in ['admin', 'manager']:
    raise PermissionDenied("Insufficient permissions")
```

**Issue: "Serializer validation errors"**

```python
# Debug validation errors
serializer = MySerializer(data=request.data)
if not serializer.is_valid():
    print(serializer.errors)  # Log errors
    return Response(serializer.errors, status=400)

# Common validation issues:
# - Required fields missing
# - Wrong field types
# - Custom validation failures
# - Unique constraints

# Check field requirements
class MySerializer(serializers.ModelSerializer):
    class Meta:
        model = MyModel
        fields = ['field1', 'field2']
        required = ['field1']  # Only if not in model

# Debug custom validation
def validate(self, data):
    print(f"Validating: {data}")  # Debug
    # ... validation logic
```

**Issue: "Relation fields with many=True"**

```python
# Nested serialization issues
class TaskSerializer(serializers.ModelSerializer):
    comments = CommentSerializer(many=True, read_only=True)
    
    # If you get 'object has no attribute 'comments''
    # Check related_name in models
    class Meta:
        model = Task
        fields = ['id', 'title', 'comments']
```

### 1.3 Database Issues

**Issue: "IntegrityError: duplicate key value violates unique constraint"**

```python
# Check for duplicate data
from django.db import IntegrityError

try:
    obj.save()
except IntegrityError:
    # Handle duplicate
    obj = MyModel.objects.get(unique_field=value)
    obj.update(data)

# Check model constraints
class MyModel(models.Model):
    class Meta:
        unique_together = [['field1', 'field2']]
        # Or use unique=True on field
```

**Issue: "PostgreSQL: FATAL: connection limit exceeded"**

```bash
# Check connection count
psql -U postgres -c "SELECT count(*) FROM pg_stat_activity;"

# Increase max_connections
# Edit postgresql.conf
max_connections = 200

# Or in Docker
docker-compose exec db psql -U postgres -c "ALTER SYSTEM SET max_connections = 200;"
docker-compose restart db

# Check connection pooling settings
# In Django settings
DATABASES['default']['CONN_MAX_AGE'] = 600  # Reduce if too high
```

### 1.4 Redis Issues

**Issue: "redis.exceptions.ConnectionError: Error 111 connecting to localhost:6379"**

```bash
# Check if Redis is running
redis-cli ping

# Start Redis
sudo systemctl start redis  # Linux
brew services start redis  # macOS
docker-compose up -d redis  # Docker

# Check Redis config
redis-cli CONFIG GET bind
redis-cli CONFIG GET port

# Test connection
redis-cli -h localhost -p 6379
```

**Issue: "Redis: MISCONF Redis is configured to save RDB snapshots"**

```bash
# Fix Redis persistence errors
redis-cli CONFIG SET stop-writes-on-bgsave-error no

# Check disk space
df -h

# Clear Redis data
redis-cli FLUSHALL

# Or restart Redis
sudo systemctl restart redis
```

---

## Section 2: Frontend Troubleshooting

### 2.1 Next.js Issues

**Issue: "Error: Module not found: Can't resolve '@/components/Button'"**

```javascript
// Check path alias in tsconfig.json
{
    "compilerOptions": {
        "paths": {
            "@/*": ["./*"]
        }
    }
}

// Also check in next.config.js
module.exports = {
    webpack: (config) => {
        config.resolve.alias['@'] = path.join(__dirname);
        return config;
    },
};
```

**Issue: "Hydration error: Text content does not match server-rendered HTML"**

```tsx
// Common causes:
// 1. Using client-only data in server component
'use client';  // Add this for client-only components

// 2. Using window/document in server component
if (typeof window !== 'undefined') {
    // Client-only code
}

// 3. Random values that differ between server and client
const randomId = Math.random().toString(36);  // ❌
// Use a fixed key or id
```

**Issue: "Error: 'useState' is not allowed in Server Components"**

```tsx
// ❌ Bad: Using hooks in Server Component
export default function Page() {
    const [count, setCount] = useState(0);  // Error!
    return <div>{count}</div>;
}

// ✅ Good: Move to Client Component
'use client';
export default function Counter() {
    const [count, setCount] = useState(0);
    return <div>{count}</div>;
}
```

**Issue: "API route returns 404"**

```typescript
// Check file structure
// app/api/users/route.ts
export async function GET(request: Request) {
    return NextResponse.json({ data: 'ok' });
}

// Check method exports
export async function POST(request: Request) { ... }
export async function PUT(request: Request) { ... }
export async function DELETE(request: Request) { ... }

// Check route path
// - /app/api/users/route.ts → /api/users
// - /app/api/users/[id]/route.ts → /api/users/1
```

### 2.2 React Issues

**Issue: "Key prop missing in list"**

```tsx
// ❌ Bad
{tasks.map((task) => (
    <TaskItem task={task} />  // Warning: key missing
))}

// ✅ Good
{tasks.map((task) => (
    <TaskItem key={task.id} task={task} />
))}
```

**Issue: "Invalid hook call"**

```tsx
// ❌ Bad: Hook called conditionally
function MyComponent({ condition }) {
    if (condition) {
        useState(0);  // Error!
    }
}

// ✅ Good: Hook called unconditionally
function MyComponent({ condition }) {
    const [state, setState] = useState(0);
    // Use state based on condition
}

// ❌ Bad: Hook called in loop
function MyComponent() {
    for (let i = 0; i < 5; i++) {
        useState(0);  // Error!
    }
}

// ✅ Good: Use array or object state
function MyComponent() {
    const [items, setItems] = useState(Array(5).fill(0));
}
```

### 2.3 TypeScript Issues

**Issue: "TS2339: Property 'x' does not exist on type 'Y'"**

```typescript
// Define proper types
interface Task {
    id: number;
    title: string;
    status: string;
}

// ❌ Bad: Using any
const task: any = getTask();

// ✅ Good: Use proper type
const task: Task = getTask();

// ✅ Or use type assertion (if you're sure)
const task = getTask() as Task;
```

**Issue: "TS7006: Parameter 'x' implicitly has an 'any' type"**

```typescript
// Add types to function parameters
function processTask(task: Task) { ... }

// Or configure tsconfig to allow implicit any (not recommended)
{
    "compilerOptions": {
        "noImplicitAny": false
    }
}
```

### 2.4 React Query Issues

**Issue: "useQuery is not working"**

```tsx
// Check provider is set up
function RootLayout({ children }) {
    return (
        <QueryClientProvider client={queryClient}>
            {children}
        </QueryClientProvider>
    );
}

// Check query key
useQuery({
    queryKey: ['tasks', { status: 'todo' }],
    queryFn: () => fetchTasks({ status: 'todo' }),
});

// Enable query for dynamic id
useQuery({
    queryKey: ['task', id],
    queryFn: () => fetchTask(id),
    enabled: !!id,  // Only when id exists
});
```

---

## Section 3: Docker Troubleshooting

### 3.1 Build Issues

**Issue: "failed to compute cache key"**

```dockerfile
# ❌ Bad: Build context issue
COPY . .

# ✅ Good: Build context includes all needed files
# Check .dockerignore

# ❌ Bad: Missing files
COPY requirements.txt .  # File doesn't exist

# ✅ Good: Check file exists
ls -la requirements.txt
```

**Issue: "no space left on device"**

```bash
# Clean Docker cache
docker system prune -a

# Clean specific resources
docker image prune -a
docker container prune
docker volume prune
docker builder prune

# Check disk usage
docker system df
df -h

# Increase disk space (Docker Desktop)
# Settings → Resources → Disk image size
```

**Issue: "cannot connect to the Docker daemon"**

```bash
# Start Docker Desktop
# Or on Linux:
sudo systemctl start docker
sudo systemctl enable docker

# Check permissions
sudo usermod -aG docker $USER
newgrp docker

# Check Docker socket
ls -la /var/run/docker.sock
```

### 3.2 Runtime Issues

**Issue: "Port already in use"**

```bash
# Find process using port
sudo lsof -i :8000
# or
netstat -tulpn | grep 8000

# Kill process
kill -9 PID

# Or use different port
docker run -p 8001:8000 image_name
```

**Issue: "Permission denied" when accessing volumes**

```yaml
# docker-compose.yml
services:
  backend:
    volumes:
      - ./app_data:/data
      # Add :Z for SELinux (Linux)
      - ./app_data:/data:Z
      # :z if multiple containers access
      - ./app_data:/data:z
```

**Issue: "Health check failing"**

```bash
# Check health status
docker inspect container_name --format='{{.State.Health}}'

# Disable health check for debugging
docker run --no-healthcheck image_name

# Test health check manually
curl http://localhost:8000/health/
```

---

## Section 4: Production Issues

### 4.1 Deployment Issues

**Issue: "500 Internal Server Error"**

```bash
# Check application logs
docker-compose logs backend | grep ERROR

# Check Django debug mode
# Set DEBUG=True temporarily for debugging
# BUT BE CAREFUL in production!

# Check static files
python manage.py collectstatic --noinput

# Check database migrations
python manage.py migrate

# Check environment variables
docker-compose exec backend env
```

**Issue: "Connection refused" between containers**

```yaml
# Check service names in docker-compose.yml
services:
  backend:
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/db  # 'db' is service name

  # Check networks
  networks:
    - taskflow-network

# Test connectivity
docker-compose exec backend ping db
docker-compose exec backend nslookup db
```

### 4.2 Performance Issues

**Issue: "Slow response times"**

```bash
# Check query count
# Add DEBUG=True and check Django debug toolbar

# Check database performance
# Add indexes
# Optimize queries

# Check caching
# Ensure Redis is working
redis-cli ping

# Check worker count
# Increase Gunicorn workers
GUNICORN_WORKERS=4

# Check resource usage
docker stats
top
htop
```

### 4.3 Security Issues

**Issue: "CSRF token missing or incorrect"**

```python
# Django
# Ensure CSRF middleware is enabled
MIDDLEWARE = [
    'django.middleware.csrf.CsrfViewMiddleware',
]

# For API endpoints using JWT
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
}

# For form submissions
<form method="post">
    {% csrf_token %}
</form>
```

**Issue: "CORS error"**

```python
# Django settings
CORS_ALLOWED_ORIGINS = [
    'https://app.taskflow.com',
    'https://www.taskflow.com',
]

CORS_ALLOW_CREDENTIALS = True
CORS_ALLOW_METHODS = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS']
CORS_ALLOW_HEADERS = ['accept', 'accept-encoding', 'authorization', 'content-type']
```

---

## Section 5: Quick Reference Commands

### Debug Commands

```bash
# Django shell
python manage.py shell

# Check database queries
from django.db import connection
print(connection.queries)

# Check cache
from django.core.cache import cache
cache.get('some_key')

# Check Redis
redis-cli -n 1 KEYS "task:*"

# Check PostgreSQL
psql -U postgres -d taskflow_db -c "SELECT * FROM pg_stat_activity;"
```

### Log Commands

```bash
# Django logs
tail -f logs/django.log

# Docker logs
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f nginx

# System logs
journalctl -u django  # Linux
sudo tail -f /var/log/nginx/error.log
```

### Clean Commands

```bash
# Python
find . -type f -name "*.pyc" -delete
find . -type d -name "__pycache__" -delete

# Node
rm -rf node_modules .next

# Docker
docker system prune -a
docker volume prune
docker builder prune

# Redis
redis-cli FLUSHALL

# Database
python manage.py flush  # Reset database
python manage.py reset_db  # Django-extensions
```

---

## Common Error Codes

| Error | Meaning | Solution |
|-------|---------|----------|
| 400 | Bad Request | Check request format |
| 401 | Unauthorized | Provide valid token |
| 403 | Forbidden | Check permissions |
| 404 | Not Found | Check URL |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Check logs |
| 502 | Bad Gateway | Nginx can't reach backend |
| 503 | Service Unavailable | Service down |
| 504 | Gateway Timeout | Request too slow |

---

*This concludes Appendix K. Use this troubleshooting guide to quickly resolve common issues.*
