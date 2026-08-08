# Appendix W: Complete Technology Stack Reference

## Full Stack Reference Guide

Welcome to **Appendix W** of the Django REST Framework & Next.js 16 masterclass. This appendix provides a comprehensive reference for all technologies used throughout the series, including version information, key features, and configuration references.

---

## Section 1: Backend Technologies

### 1.1 Python

| Version | Release Date | Key Features |
|---------|--------------|--------------|
| Python 3.12 | October 2023 | Pattern matching, type hint improvements, perf improvements |
| Python 3.13 | (Future) | JIT compilation, new type features |

**Key Features Used:**
- Type hints (`typing`)
- Async/await
- Pattern matching
- Dataclasses
- f-strings
- List/dict comprehensions

**Common Commands:**
```bash
# Create virtual environment
python -m venv venv

# Install dependencies
pip install -r requirements.txt

# Run Python shell
python manage.py shell
```

---

### 1.2 Django 6.x

**Key Features:**
- ORM
- Admin interface
- Authentication
- URL routing
- Templates
- Migrations

**Settings Reference:**
```python
# Minimal settings
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'taskflow_db',
        'USER': 'taskflow_user',
        'PASSWORD': 'password',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
```

---

### 1.3 Django REST Framework (DRF) 3.15.x

**Key Features:**
- Serializers
- ViewSets
- Routers
- Authentication
- Permissions
- Throttling
- Pagination
- Filtering

**Settings Reference:**
```python
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
}
```

**Serializer Types:**
- `Serializer` - Base
- `ModelSerializer` - Auto-generated
- `HyperlinkedModelSerializer` - Hyperlinks for relationships
- `ListSerializer` - For lists

**View Types:**
- `@api_view` - Function-based
- `APIView` - Class-based
- `GenericAPIView` - Generic
- `ListCreateAPIView` - List/Create
- `RetrieveUpdateDestroyAPIView` - Full CRUD
- `ModelViewSet` - Complete CRUD with ViewSet

---

### 1.4 SimpleJWT 5.3.x

**Key Features:**
- JWT authentication
- Token refresh
- Token blacklisting
- Token rotation

**Settings Reference:**
```python
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=15),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'UPDATE_LAST_LOGIN': True,
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': SECRET_KEY,
    'AUTH_HEADER_TYPES': ('Bearer',),
}
```

**Token Endpoints:**
```bash
POST /api/v1/token/       # Obtain token
POST /api/v1/token/refresh/ # Refresh token
POST /api/v1/token/verify/   # Verify token
```

---

### 1.5 Django Filter

**Key Features:**
- Filtering querysets
- Search
- Custom filters
- Filter sets

**Usage:**
```python
class TaskFilter(filters.FilterSet):
    status = filters.CharFilter(field_name='status')
    priority = filters.CharFilter(field_name='priority')
    
    class Meta:
        model = Task
        fields = ['status', 'priority', 'project']
```

---

### 1.6 Gunicorn

**Key Features:**
- WSGI HTTP server
- Worker management
- Preloading
- Graceful shutdown

**Common Configuration:**
```python
workers = 4
worker_class = 'sync'
timeout = 30
max_requests = 1000
preload_app = True
```

**Run Commands:**
```bash
gunicorn --workers=4 --bind=0.0.0.0:8000 config.wsgi
gunicorn -c gunicorn.conf.py config.wsgi
```

---

## Section 2: Frontend Technologies

### 2.1 Next.js 16

**Key Features:**
- App Router
- Server Components
- Client Components
- API Routes
- Image Optimization
- Font Optimization
- CSS Support (Tailwind)
- Middleware

**Directory Structure:**
```
app/
├── (auth)/              # Route group
├── (dashboard)/         # Route group
├── api/                 # API routes
├── layout.tsx           # Root layout
├── page.tsx             # Root page
├── loading.tsx          # Loading UI
├── error.tsx            # Error UI
└── globals.css          # Global styles
```

**Configuration:**
```javascript
// next.config.js
module.exports = {
    output: 'standalone',
    images: {
        domains: ['localhost'],
    },
    async headers() {
        return [
            {
                source: '/:path*',
                headers: [
                    { key: 'X-Frame-Options', value: 'DENY' },
                ],
            },
        ];
    },
};
```

---

### 2.2 React 19

**Key Features:**
- Hooks (useState, useEffect, useContext, useReducer)
- Server Components
- Suspense
- Concurrent features
- React Compiler (future)

**Component Types:**
- Functional Components
- Class Components
- Server Components
- Client Components ('use client')

**Common Hooks:**
```typescript
// State
const [state, setState] = useState(initial)

// Side effects
useEffect(() => { ... }, [dependencies])

// Context
const context = useContext(Context)

// Reducer
const [state, dispatch] = useReducer(reducer, initialState)

// Memoization
const memoized = useMemo(() => expensive(), [deps])
const callback = useCallback(() => { ... }, [deps])

// Refs
const ref = useRef(initialValue)
```

---

### 2.3 React Query (TanStack Query) 5.x

**Key Features:**
- Data fetching
- Caching
- Synchronization
- Pagination
- Infinite queries
- Optimistic updates

**Common Hooks:**
```typescript
// Query
const { data, isLoading, error } = useQuery({
    queryKey: ['tasks', filters],
    queryFn: () => fetchTasks(filters),
    staleTime: 60000,
})

// Mutation
const mutation = useMutation({
    mutationFn: createTask,
    onSuccess: () => {
        queryClient.invalidateQueries({ queryKey: ['tasks'] })
    },
})

// Infinite Query
const { data, fetchNextPage, hasNextPage } = useInfiniteQuery({
    queryKey: ['tasks'],
    queryFn: ({ pageParam = 1 }) => fetchTasks({ page: pageParam }),
    getNextPageParam: (lastPage) => lastPage.next_page,
    initialPageParam: 1,
})
```

---

### 2.4 Tailwind CSS 3.x

**Key Features:**
- Utility-first CSS
- Custom theming
- Responsive design
- Dark mode
- Plugins

**Configuration:**
```javascript
// tailwind.config.js
module.exports = {
    content: [
        './app/**/*.{js,ts,jsx,tsx}',
        './components/**/*.{js,ts,jsx,tsx}',
    ],
    theme: {
        extend: {
            colors: {
                primary: {
                    50: '#eff6ff',
                    500: '#3b82f6',
                    600: '#2563eb',
                },
            },
        },
    },
    plugins: [],
}
```

**Common Utilities:**
```html
<div class="flex items-center justify-between p-4 bg-white rounded-lg shadow-md">
    <h1 class="text-2xl font-bold text-gray-900">Title</h1>
    <button class="px-4 py-2 text-white bg-blue-600 rounded-lg hover:bg-blue-700">
        Button
    </button>
</div>
```

---

## Section 3: Database Technologies

### 3.1 PostgreSQL 15+

**Key Features:**
- ACID compliance
- Advanced indexing
- Full-text search
- JSON support
- Window functions
- Transaction isolation
- MVCC

**Common SQL Patterns:**
```sql
-- Create table
CREATE TABLE tasks (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    status VARCHAR(20) DEFAULT 'todo',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index
CREATE INDEX idx_tasks_status ON tasks(status);

-- Full-text search
CREATE INDEX idx_tasks_search ON tasks USING GIN(to_tsvector('english', title));

-- JSON query
SELECT data->>'name' FROM json_table WHERE data->>'status' = 'active';
```

---

### 3.2 Redis 7.x

**Key Features:**
- In-memory data store
- Persistence
- Data structures (strings, hashes, lists, sets, sorted sets)
- Pub/Sub
- Lua scripting
- Transactions

**Common Commands:**
```bash
# Strings
SET key value
GET key
INCR key

# Hashes
HSET hash field value
HGET hash field
HGETALL hash

# Lists
LPUSH list value
RPUSH list value
LRANGE list 0 -1

# Sets
SADD set member
SMEMBERS set

# Sorted Sets
ZADD sorted_set score member
ZRANGE sorted_set 0 -1
```

---

## Section 4: DevOps Technologies

### 4.1 Docker

**Key Concepts:**
- Images
- Containers
- Volumes
- Networks
- Registries

**Common Commands:**
```bash
# Images
docker build -t image:tag .
docker images
docker rmi image:tag

# Containers
docker run -d --name container image
docker ps
docker stop container
docker rm container

# Volumes
docker volume create volume
docker run -v volume:/path image

# Networks
docker network create network
docker run --network network image
```

### 4.2 Docker Compose

**Key Concepts:**
- Services
- Networks
- Volumes
- Environment
- Dependencies

**Example:**
```yaml
version: '3.8'
services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://db:5432/db
    depends_on:
      - db

  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=taskflow_db
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

---

### 4.3 Nginx

**Key Features:**
- Reverse proxy
- Load balancing
- SSL/TLS termination
- Caching
- Compression
- Rate limiting

**Example Configuration:**
```nginx
server {
    listen 80;
    server_name api.example.com;

    location / {
        proxy_pass http://backend:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

---

## Section 5: CI/CD Technologies

### 5.1 GitHub Actions

**Key Components:**
- Workflows
- Jobs
- Steps
- Actions
- Runners

**Example:**
```yaml
name: CI
on: push
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: pytest
```

---

### 5.2 Monitoring Technologies

**Prometheus:**
- Metrics collection
- Time-series database
- Alerting

**Grafana:**
- Dashboards
- Visualization
- Alerting

**Sentry:**
- Error tracking
- Performance monitoring
- Issue resolution

---

## Section 6: Version Compatibility Matrix

| Component | Version | Status |
|-----------|---------|--------|
| Python | 3.12+ | ✅ Supported |
| Django | 6.x | ✅ Supported |
| DRF | 3.15.x | ✅ Supported |
| SimpleJWT | 5.3.x | ✅ Supported |
| PostgreSQL | 15+ | ✅ Supported |
| Redis | 7.x | ✅ Supported |
| Next.js | 16.x | ✅ Supported |
| React | 19.x | ✅ Supported |
| Node.js | 20+ | ✅ Supported |
| Docker | 24+ | ✅ Supported |
| Docker Compose | 2.20+ | ✅ Supported |
| Nginx | 1.24+ | ✅ Supported |

---

*This concludes Appendix W. Use this reference to understand the full technology stack.*
