# Django REST Framework & Next.js 16: Student Notes

## Complete Course Notes for the Masterclass

---

# Part 0: Introduction & Course Overview

## Architecture Overview

### Decoupled Architecture
```
Browser (Client)
    ↓
Next.js 16 (Frontend)
    ↓ HTTP/JSON
Django REST Framework (API)
    ↓
PostgreSQL (Database) + Redis (Cache)
```

### Key Principles
- **Separation of Concerns**: Backend handles data/rules, Frontend handles UI/UX
- **Clean Client-Server Boundary**: API is the contract between systems
- **Independent Evolution**: Frontend and backend can evolve separately
- **Security**: Never rely on frontend for security enforcement

### Technology Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Language | Python | 3.12+ |
| Backend | Django | 6.x |
| API | Django REST Framework | 3.15.x |
| Authentication | JWT / SimpleJWT | 5.3.x |
| Database | PostgreSQL | 15+ |
| Cache | Redis | 7+ |
| Frontend | Next.js | 16.x |
| UI | React | 19.x |
| Styling | Tailwind CSS | 3.x |
| Testing | pytest / Jest | Latest |
| Container | Docker / Docker Compose | Latest |

## Course Structure
- **4 Phases**, **33 Parts**, **26 Appendices**, **10 Primers**
- Each part: Concept → Implementation → Verification

---

# Part 1: REST Architecture & HTTP Fundamentals

## REST Constraints
1. **Client-Server**: Separation of concerns
2. **Stateless**: No client context on server
3. **Cacheable**: Responses indicate cacheability
4. **Uniform Interface**: Consistent API design
5. **Layered System**: Multiple layers (load balancers, caches)
6. **Code on Demand**: Optional (rarely used)

## HTTP Methods

| Method | Purpose | Idempotent | Safe | Body |
|--------|---------|------------|------|------|
| GET | Retrieve | Yes | Yes | No |
| POST | Create | No | No | Yes |
| PUT | Replace | Yes | No | Yes |
| PATCH | Update | No | No | Yes |
| DELETE | Delete | Yes | No | No |

## HTTP Status Codes

### 2xx - Success
- **200 OK**: Request succeeded
- **201 Created**: Resource created
- **204 No Content**: Success, no body

### 4xx - Client Errors
- **400 Bad Request**: Invalid request
- **401 Unauthorized**: Authentication required
- **403 Forbidden**: Not authorized
- **404 Not Found**: Resource doesn't exist
- **422 Unprocessable Entity**: Validation error
- **429 Too Many Requests**: Rate limit exceeded

### 5xx - Server Errors
- **500 Internal Server Error**: Generic server error
- **502 Bad Gateway**: Invalid upstream response
- **503 Service Unavailable**: Server temporarily unavailable

## URL Design Best Practices
```
✅ /api/users              - Collection
✅ /api/users/{id}         - Resource
✅ /api/users/{id}/projects - Nested resource
❌ /api/getUser?id=1       - Verb in URL
❌ /api/createUser         - Verb in URL
```

---

# Part 2: Django 6 Backend Foundations

## Project Setup

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements/base.txt

# Create project
django-admin startproject config .

# Create apps
python manage.py startapp users apps/users
python manage.py startapp projects apps/projects
python manage.py startapp tasks apps/tasks
python manage.py startapp comments apps/comments
```

## Data Model

```
User (extends AbstractUser)
 ├── email (unique, used for auth)
 ├── bio (optional)
 ├── role (admin, manager, member, viewer)
 └── Projects (created_by FK)
 
Project
 ├── name, description
 ├── created_by (FK to User)
 └── Tasks (FK)
 
Task
 ├── title, description
 ├── status (todo, in_progress, review, done)
 ├── priority (low, medium, high, urgent)
 ├── due_date (optional)
 ├── project (FK to Project)
 ├── assigned_to (FK to User, optional)
 └── Comments (FK)
 
Comment
 ├── content
 ├── task (FK to Task)
 └── author (FK to User)
```

## Key Field Types
- `CharField(max_length)` - String with max length
- `TextField` - Unlimited string
- `ForeignKey` - Many-to-one relationship
- `DateTimeField` - Date and time
- `EmailField` - Email validation
- `BooleanField` - True/False

## Migrations
```bash
# Create migrations
python manage.py makemigrations

# Apply migrations
python manage.py migrate

# Check status
python manage.py showmigrations

# Create superuser
python manage.py createsuperuser
```

---

# Part 3: DRF Serializers

## Serializer Types

| Type | Use Case |
|------|----------|
| `Serializer` | Manual field definitions |
| `ModelSerializer` | Auto-generated from model |
| `HyperlinkedModelSerializer` | Hyperlinks for relationships |

## Basic ModelSerializer

```python
class TaskSerializer(serializers.ModelSerializer):
    project_name = serializers.CharField(source='project.name', read_only=True)
    
    class Meta:
        model = Task
        fields = ['id', 'title', 'description', 'status', 'project_name']
        read_only_fields = ['created_at', 'updated_at']
```

## Validation

### Field-Level Validation
```python
def validate_title(self, value):
    if len(value.strip()) < 3:
        raise serializers.ValidationError("Title too short")
    return value
```

### Object-Level Validation
```python
def validate(self, data):
    if data.get('due_date') and data['due_date'] < timezone.now():
        raise serializers.ValidationError("Due date must be in future")
    return data
```

## Different Serializers for Different Actions

```python
class TaskListSerializer(serializers.ModelSerializer):
    """Lightweight for list views"""
    class Meta:
        model = Task
        fields = ['id', 'title', 'status', 'priority', 'created_at']

class TaskDetailSerializer(serializers.ModelSerializer):
    """Full for detail views"""
    project = ProjectSerializer(read_only=True)
    comments = CommentSerializer(many=True, read_only=True)
    
    class Meta:
        model = Task
        fields = '__all__'
```

---

# Part 4: Building API Views

## View Types

```
Function-Based Views (@api_view)
         ↓
Class-Based Views (APIView)
         ↓
Generic Views (ListCreateAPIView, etc.)
         ↓
ViewSets (ModelViewSet)
```

## @api_view Example

```python
@api_view(['GET', 'POST'])
def task_list(request):
    if request.method == 'GET':
        tasks = Task.objects.all()
        serializer = TaskSerializer(tasks, many=True)
        return Response(serializer.data)
    
    elif request.method == 'POST':
        serializer = TaskCreateSerializer(data=request.data)
        if serializer.is_valid():
            task = serializer.save(created_by=request.user)
            return Response(TaskSerializer(task).data, status=201)
        return Response(serializer.errors, status=400)
```

## CRUD Endpoint Map

| Operation | Method | URL | Body | Response |
|-----------|--------|-----|------|----------|
| Create | POST | /api/tasks/ | Task data | 201 |
| List | GET | /api/tasks/ | None | 200 |
| Detail | GET | /api/tasks/{id}/ | None | 200 |
| Update | PUT/PATCH | /api/tasks/{id}/ | Update data | 200 |
| Delete | DELETE | /api/tasks/{id}/ | None | 204 |

---

# Part 5: Next.js 16 Foundations

## App Router Structure

```
app/
├── (auth)/              # Route group (no URL impact)
│   ├── login/
│   │   └── page.tsx     → /login
│   └── register/
│       └── page.tsx     → /register
├── (dashboard)/         # Route group
│   ├── dashboard/
│   │   └── page.tsx     → /dashboard
│   ├── projects/
│   │   ├── page.tsx     → /projects
│   │   └── [id]/
│   │       └── page.tsx → /projects/123
│   └── tasks/
│       └── page.tsx     → /tasks
├── layout.tsx           # Root layout
├── page.tsx             → /
└── globals.css          # Global styles
```

## Server vs Client Components

| Feature | Server Component | Client Component |
|---------|------------------|------------------|
| Directive | (default) | `'use client'` |
| Async/Await | ✅ | ❌ |
| React Hooks | ❌ | ✅ |
| Browser APIs | ❌ | ✅ |
| Event Handlers | ❌ | ✅ |
| SEO | ✅ Excellent | ❌ Limited |

### Server Component Example
```tsx
export default async function TaskList() {
    const tasks = await getTasks();
    return <div>{/* Render tasks */}</div>;
}
```

### Client Component Example
```tsx
'use client';
import { useState } from 'react';

export default function Counter() {
    const [count, setCount] = useState(0);
    return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

## Tailwind CSS
- **Utility-first**: Pre-built classes for styling
- **Configuration**: `tailwind.config.js`
- **Customization**: Extend theme in config

---

# Part 6: Connecting Next.js to DRF

## API Client

```typescript
// lib/api/client.ts
const API_URL = process.env.NEXT_PUBLIC_API_URL;

export async function get<T>(endpoint: string): Promise<T> {
    const response = await fetch(`${API_URL}${endpoint}`);
    if (!response.ok) throw new Error(`API Error: ${response.status}`);
    return response.json();
}

export async function post<T>(endpoint: string, data: any): Promise<T> {
    const response = await fetch(`${API_URL}${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
    });
    if (!response.ok) throw new Error(`API Error: ${response.status}`);
    return response.json();
}
```

## Data Fetching Patterns

### Server Component Fetching
```tsx
export default async function TasksPage() {
    const tasks = await get<Task[]>('/tasks/');
    return <TaskList initialTasks={tasks} />;
}
```

### Client Component Fetching (React Query)
```tsx
'use client';
export function TaskList() {
    const { data, isLoading } = useQuery({
        queryKey: ['tasks'],
        queryFn: () => get<Task[]>('/tasks/'),
    });
    if (isLoading) return <Loading />;
    return <div>{/* Render */}</div>;
}
```

## Form Handling
```tsx
'use client';
export function TaskForm() {
    const [loading, setLoading] = useState(false);
    const [errors, setErrors] = useState({});
    
    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        const response = await post('/tasks/', formData);
        if (response.error) setErrors(response.error);
        else router.push('/tasks');
        setLoading(false);
    };
}
```

---

# Part 7: CRUD Operations Across the Stack

## Complete CRUD Endpoint Map

| Resource | Create | Read (List) | Read (Detail) | Update | Delete |
|----------|--------|-------------|---------------|--------|--------|
| Users | POST /users/ | GET /users/ | GET /users/{id}/ | PUT/PATCH | DELETE |
| Projects | POST /projects/ | GET /projects/ | GET /projects/{id}/ | PUT/PATCH | DELETE |
| Tasks | POST /tasks/ | GET /tasks/ | GET /tasks/{id}/ | PUT/PATCH | DELETE |
| Comments | POST /comments/ | GET /comments/ | GET /comments/{id}/ | PUT/PATCH | DELETE |

## Data Flow
```
User Action → Client → API → Database → Response → UI Update
```

## Toast Notifications
- **Success**: Green, auto-dismiss after 3s
- **Error**: Red, manual dismiss
- **Warning**: Yellow, auto-dismiss after 5s
- **Info**: Blue, auto-dismiss after 4s

## Confirmation Modal
- Prevent accidental deletions
- Show warning for destructive actions
- Require explicit confirmation

---

# Part 8: Generic Views, ViewSets & Routers

## ViewSet Actions

| HTTP Method | URL | Action | Description |
|-------------|-----|--------|-------------|
| GET | /tasks/ | `list()` | List all tasks |
| POST | /tasks/ | `create()` | Create task |
| GET | /tasks/{id}/ | `retrieve()` | Get task |
| PUT | /tasks/{id}/ | `update()` | Full update |
| PATCH | /tasks/{id}/ | `partial_update()` | Partial update |
| DELETE | /tasks/{id}/ | `destroy()` | Delete task |

## ViewSet Example

```python
class TaskViewSet(viewsets.ModelViewSet):
    queryset = Task.objects.all()
    serializer_class = TaskSerializer
    
    def get_serializer_class(self):
        if self.action == 'create':
            return TaskCreateSerializer
        return TaskSerializer
    
    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)
```

## Custom Actions

```python
@action(detail=True, methods=['post'])
def complete(self, request, pk=None):
    task = self.get_object()
    task.status = 'done'
    task.save()
    return Response({'status': 'completed'})

@action(detail=False, methods=['get'])
def stats(self, request):
    return Response({
        'total': Task.objects.count(),
        'done': Task.objects.filter(status='done').count(),
    })
```

## Router

```python
router = DefaultRouter()
router.register(r'tasks', TaskViewSet, basename='task')
urlpatterns = router.urls
```

---

# Part 9: Advanced Querying

## django-filter

### Basic Filter
```python
class TaskFilter(FilterSet):
    status = filters.ChoiceFilter(choices=Task.Status.choices)
    priority = filters.ChoiceFilter(choices=Task.Priority.choices)
    
    class Meta:
        model = Task
        fields = ['status', 'priority', 'project', 'assigned_to']
```

### Custom Filter Methods
```python
search = filters.CharFilter(method='filter_search')

def filter_search(self, queryset, name, value):
    return queryset.filter(
        Q(title__icontains=value) |
        Q(description__icontains=value)
    )
```

### Query Parameters
```
?status=in_progress
?priority=high
?search=api
?created_after=2026-01-15T00:00:00Z
?project_name=masterclass
?ordering=-created_at
```

## Search & Ordering
```python
filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
search_fields = ['title', 'description']
ordering_fields = ['created_at', 'priority', 'status']
ordering = ['-created_at']
```

---

# Part 10: Pagination

## Pagination Strategies

| Strategy | URL Pattern | Use Case |
|----------|-------------|----------|
| Page Number | `?page=2&page_size=20` | Most use cases |
| Limit Offset | `?limit=20&offset=40` | Position-based |
| Cursor | `?cursor=encoded` | Infinite scrolling |

## Custom Pagination

```python
class CustomPageNumberPagination(pagination.PageNumberPagination):
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100
    
    def get_paginated_response(self, data):
        return Response({
            'links': {
                'next': self.get_next_link(),
                'previous': self.get_previous_link(),
            },
            'count': self.page.paginator.count,
            'page_size': self.get_page_size(self.request),
            'current_page': self.page.number,
            'total_pages': self.page.paginator.num_pages,
            'results': data,
        })
```

## Pagination Response
```json
{
    "count": 100,
    "next": "http://api.example.com/tasks?page=3",
    "previous": "http://api.example.com/tasks?page=1",
    "page_size": 20,
    "current_page": 2,
    "total_pages": 5,
    "results": [...]
}
```

---

# Part 11: Next.js Routing & Navigation

## Route Types

| Type | Pattern | URL |
|------|---------|-----|
| Static | `page.tsx` | `/about` |
| Dynamic | `[id]/page.tsx` | `/123` |
| Catch-all | `[...slug]/page.tsx` | `/a/b/c` |
| Route Group | `(group)/page.tsx` | `/page` |

## Route Groups
```
app/
├── (auth)/              # No /auth in URL
│   ├── login/           → /login
│   └── register/        → /register
├── (dashboard)/         # No /dashboard in URL
│   ├── projects/        → /projects
│   └── tasks/           → /tasks
```

## Layouts
```tsx
// app/(dashboard)/layout.tsx
export default function DashboardLayout({ children }) {
    return (
        <div>
            <Sidebar />
            <main>{children}</main>
        </div>
    );
}
```

## Loading & Error States
```tsx
// app/(dashboard)/loading.tsx
export default function Loading() {
    return <div className="animate-spin">Loading...</div>;
}

// app/(dashboard)/error.tsx
'use client';
export default function Error({ error, reset }) {
    return (
        <div>
            <h2>Something went wrong!</h2>
            <button onClick={reset}>Try again</button>
        </div>
    );
}
```

---

# Part 12: Frontend Data Architecture

## React Query Setup

```tsx
// QueryProvider.tsx
export function QueryProvider({ children }) {
    const [queryClient] = useState(() => new QueryClient({
        defaultOptions: {
            queries: {
                staleTime: 60 * 1000,
                gcTime: 5 * 60 * 1000,
                retry: 1,
                refetchOnWindowFocus: false,
            },
        },
    }));
    
    return (
        <QueryClientProvider client={queryClient}>
            {children}
            <ReactQueryDevtools />
        </QueryClientProvider>
    );
}
```

## Data Fetching Hooks

```tsx
export function useTasks(filters = {}) {
    return useQuery({
        queryKey: ['tasks', filters],
        queryFn: () => get<Task[]>(ENDPOINTS.tasks.list, filters),
    });
}
```

## Mutations & Optimistic Updates

```tsx
export function useCreateTask() {
    const queryClient = useQueryClient();
    
    return useMutation({
        mutationFn: (data) => post(ENDPOINTS.tasks.list, data),
        onMutate: async (newTask) => {
            await queryClient.cancelQueries({ queryKey: ['tasks'] });
            const previous = queryClient.getQueryData(['tasks']);
            queryClient.setQueryData(['tasks'], (old) => ({
                ...old,
                results: [newTask, ...old.results],
            }));
            return { previous };
        },
        onError: (err, newTask, context) => {
            queryClient.setQueryData(['tasks'], context?.previous);
        },
        onSettled: () => {
            queryClient.invalidateQueries({ queryKey: ['tasks'] });
        },
    });
}
```

## Cache Invalidation Strategies
1. **Time-based**: `staleTime` configuration
2. **On-demand**: `invalidateQueries()` after mutations
3. **Navigation-based**: `router.refresh()` on route change
4. **Optimistic**: Update UI immediately, revalidate in background

---

# Part 13: Searchable Data Interfaces

## URL State Management

```tsx
export function useUrlState<T>() {
    const router = useRouter();
    const searchParams = useSearchParams();
    
    const state = useMemo(() => {
        const params: Record<string, any> = {};
        searchParams.forEach((value, key) => {
            if (value && !isNaN(Number(value))) {
                params[key] = Number(value);
            } else if (value === 'true') {
                params[key] = true;
            } else if (value === 'false') {
                params[key] = false;
            } else {
                params[key] = value;
            }
        });
        return params as T;
    }, [searchParams]);
    
    const updateState = useCallback((updates: Partial<T>) => {
        const params = new URLSearchParams(searchParams.toString());
        Object.entries(updates).forEach(([key, value]) => {
            if (value === undefined || value === null || value === '') {
                params.delete(key);
            } else {
                params.set(key, String(value));
            }
        });
        router.push(`?${params.toString()}`);
    }, [router, searchParams]);
    
    return { state, updateState };
}
```

## URL Benefits
- Shareable links
- Bookmarkable views
- Browser navigation works
- Server-side state available

## Data Table Components
1. **DataTable**: Reusable table with sorting
2. **DataTableHeader**: Sortable headers
3. **DataTableToolbar**: Search + filters
4. **Pagination**: Page navigation
5. **PageSizeSelector**: Items per page

## Combined Filtering Flow
```
User Action → Update URL State → React Query → Data Table → Re-render
```

---

# Part 14: Authentication Architecture

## Authentication vs Authorization

| Concept | Definition | Question |
|---------|------------|----------|
| Authentication | Verify identity | "Who are you?" |
| Authorization | Check permissions | "What can you do?" |

## JWT Structure
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.
eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.
SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

### Parts
1. **Header**: Algorithm and token type
2. **Payload**: Claims (user data, expiration)
3. **Signature**: Verifies token integrity

## Token Types
- **Access Token**: Short-lived (15 min), used for API requests
- **Refresh Token**: Long-lived (7 days), used to get new access tokens

## Token Lifecycle
```
Login → Generate tokens → Store tokens → Send access token with requests
→ Token expires → Use refresh token → Get new access token
```

## SimpleJWT Configuration

```python
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=15),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'UPDATE_LAST_LOGIN': True,
    'ALGORITHM': 'HS256',
}
```

## Authentication Endpoints
- `POST /api/v1/token/` - Obtain token pair
- `POST /api/v1/token/refresh/` - Refresh access token
- `POST /api/v1/token/verify/` - Verify token validity
- `POST /api/v1/users/register/` - User registration

---

# Part 15: JWT with SimpleJWT

## Token Management (Frontend)

```typescript
// lib/auth/token.ts
export function setTokens(access: string, refresh: string) {
    localStorage.setItem('access_token', access);
    localStorage.setItem('refresh_token', refresh);
}

export function getAccessToken(): string | null {
    return localStorage.getItem('access_token');
}

export function clearTokens() {
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
}
```

## Auth Context

```tsx
export function AuthProvider({ children }) {
    const [user, setUser] = useState(null);
    
    const login = async (email, password) => {
        const response = await post('/token/', { email, password });
        setTokens(response.access, response.refresh);
        setUser(response.user);
    };
    
    const logout = () => {
        clearTokens();
        setUser(null);
        router.push('/login');
    };
}
```

## API Client Interceptor

```typescript
api.interceptors.request.use((config) => {
    const token = getAccessToken();
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

api.interceptors.response.use(
    (response) => response,
    async (error) => {
        if (error.response?.status === 401 && !originalRequest._retry) {
            originalRequest._retry = true;
            const refresh = getRefreshToken();
            const response = await post('/token/refresh/', { refresh });
            setAccessToken(response.access);
            originalRequest.headers.Authorization = `Bearer ${response.access}`;
            return api(originalRequest);
        }
        return Promise.reject(error);
    }
);
```

## Route Protection (Middleware)

```typescript
// middleware.ts
export function middleware(request: NextRequest) {
    const token = request.cookies.get('access_token');
    const path = request.nextUrl.pathname;
    
    const isPublic = ['/', '/login', '/register'].some(p => path.startsWith(p));
    const isProtected = ['/dashboard', '/projects', '/tasks'].some(p => path.startsWith(p));
    
    if (isProtected && !token) {
        return NextResponse.redirect(new URL('/login', request.url));
    }
    
    if (isPublic && token && path !== '/') {
        return NextResponse.redirect(new URL('/dashboard', request.url));
    }
    
    return NextResponse.next();
}
```

---

# Part 16: DRF Permissions

## Permission System

### View-Level Checks
```python
def has_permission(self, request, view):
    # Check authentication
    # Check role-based permissions
    return True or False
```

### Object-Level Checks
```python
def has_object_permission(self, request, view, obj):
    # Check ownership
    # Check object-specific rules
    return True or False
```

## Custom Permissions

```python
class IsProjectOwner(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.created_by == request.user

class IsTaskAssignee(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.assigned_to == request.user

class IsAdminOrManager(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.role in ['admin', 'manager']
```

## Applying Permissions

```python
class ProjectViewSet(viewsets.ModelViewSet):
    def get_permissions(self):
        if self.action == 'create':
            return [IsAuthenticated()]
        elif self.action == 'destroy':
            return [IsAuthenticated(), IsProjectOwner()]
        return [IsAuthenticated(), HasProjectAccess()]
```

## Permission Flow
```
1. Request arrives
   ↓
2. has_permission() called
   - Authenticated?
   - Has role?
   ↓
3. If True → has_object_permission() called
   - Owns object?
   - Has access?
   ↓
4. Both True → Access granted
```

---

# Part 17: Role-Based Access Control

## Role Hierarchy

```
ADMIN
  ├─ Manage users
  ├─ Manage all projects
  ├─ Manage all tasks
  └─ All permissions

MANAGER
  ├─ Manage projects
  ├─ Manage tasks
  ├─ Assign tasks
  └─ View users

MEMBER
  ├─ View assigned projects
  ├─ Update assigned tasks
  └─ Add comments

VIEWER
  ├─ View assigned projects
  ├─ View tasks
  └─ View comments
```

## Role Methods

```python
class User(AbstractUser):
    @property
    def is_admin(self):
        return self.role == self.Roles.ADMIN
    
    @property
    def is_manager(self):
        return self.role in [self.Roles.ADMIN, self.Roles.MANAGER]
    
    def has_permission(self, permission):
        permissions = {
            'manage_users': self.is_admin,
            'manage_projects': self.is_manager or self.is_admin,
            'view_tasks': self.is_member,
        }
        return permissions.get(permission, False)
```

## Frontend Role Guards

```tsx
export function RoleGuard({ children, roles, fallback = null }) {
    const { user } = useAuth();
    if (!user) return <>{fallback}</>;
    const hasRole = roles.some(role => user.role === role);
    return hasRole ? <>{children}</> : <>{fallback}</>;
}

// Usage
<RoleGuard roles={['admin']}>
    <AdminDashboard />
</RoleGuard>
```

---

# Part 18: Next.js Authentication

## Authentication Layers

1. **Middleware**: Route-level protection
2. **Server Components**: Server-side auth
3. **Client Components**: Client-side auth state
4. **API Routes**: Auth-related endpoints

## Server-Side Auth

```typescript
// lib/auth/server-auth.ts
export async function getServerUser() {
    const cookieStore = await cookies();
    const token = cookieStore.get('access_token')?.value;
    if (!token) return null;
    
    const decoded = jwtDecode(token);
    if (!decoded || !decoded.exp || Date.now() >= decoded.exp * 1000) {
        return null;
    }
    
    const response = await get('/users/profile/');
    return response.data;
}

export async function requireAuth() {
    const user = await getServerUser();
    if (!user) redirect('/login');
    return user;
}
```

## Server Component with Auth

```tsx
export default async function DashboardPage() {
    const user = await requireAuth();
    return <div>Welcome, {user.email}!</div>;
}
```

---

# Part 19: Next.js Request Interception

## Interceptor Flow

```
Request → Auth Interceptor → CSRF Interceptor → Server
         ↓
Response ← Error Interceptor ← Refresh Interceptor
```

## API Interceptor Pattern

```typescript
api.interceptors.request.use((config) => {
    const token = getAccessToken();
    if (token) config.headers.Authorization = `Bearer ${token}`;
    return config;
});

api.interceptors.response.use(
    (response) => response,
    async (error) => {
        if (error.response?.status === 401 && !originalRequest._retry) {
            originalRequest._retry = true;
            try {
                const refresh = getRefreshToken();
                const response = await post('/token/refresh/', { refresh });
                setAccessToken(response.access);
                originalRequest.headers.Authorization = `Bearer ${response.access}`;
                return api(originalRequest);
            } catch {
                clearTokens();
                window.location.href = '/login';
            }
        }
        return Promise.reject(error);
    }
);
```

---

# Part 20: API Security

## Security Layers

```
Network Layer:
├── HTTPS
├── CORS
└── Rate Limiting

Application Layer:
├── JWT Authentication
├── Permission Checks
├── Input Validation
└── SQL Injection Protection

Data Layer:
├── Encryption
├── Sanitization
└── Audit Logging
```

## Rate Limiting

```python
@ratelimit(key='ip', rate='10/m')
def login_view(request):
    pass  # 10 requests per minute

@ratelimit(key='user', rate='100/h')
def api_view(request):
    pass  # 100 requests per hour
```

## CORS Configuration

```python
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "https://app.taskflow.com",
]
CORS_ALLOW_CREDENTIALS = True
CORS_ALLOW_METHODS = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS']
```

## Security Headers

| Header | Value | Purpose |
|--------|-------|---------|
| `Strict-Transport-Security` | `max-age=31536000` | Enforce HTTPS |
| `X-Frame-Options` | `DENY` | Prevent clickjacking |
| `X-Content-Type-Options` | `nosniff` | Prevent MIME sniffing |
| `X-XSS-Protection` | `1; mode=block` | XSS protection |
| `Content-Security-Policy` | `default-src 'self'` | Resource restrictions |

---

# Part 21: Django ORM Performance

## N+1 Query Problem

```python
# Problem: N+1 queries
tasks = Task.objects.all()  # 1 query
for task in tasks:
    print(task.project.name)  # N queries

# Solution: select_related (1 query)
tasks = Task.objects.select_related('project').all()

# Solution: prefetch_related (2 queries)
tasks = Task.objects.prefetch_related('comments').all()
```

## Query Optimization Methods

| Method | Use Case |
|--------|----------|
| `select_related` | ForeignKey, OneToOne |
| `prefetch_related` | ManyToMany, reverse FK |
| `only` | Fetch specific fields |
| `defer` | Exclude large fields |
| `values` | Dictionary output |
| `values_list` | Tuple output |

## Database Indexes

```python
class Task(models.Model):
    class Meta:
        indexes = [
            models.Index(fields=['status']),
            models.Index(fields=['project', 'status']),
            models.Index(fields=['-created_at']),
            models.Index(fields=['due_date'], condition=Q(status='todo')),
        ]
```

## Performance Monitoring Tools
- **Django Debug Toolbar**: SQL queries, cache, performance
- **django-silk**: Profiling and query analysis
- **Query Count Middleware**: Log queries per request

---

# Part 22: Redis Caching

## Caching Architecture

```
Request → Cache Check → Hit → Return Cached Response
              ↓ Miss
          Database → Store in Cache → Return Response
```

## Django Redis Configuration

```python
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://localhost:6379/1',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
            'CONNECTION_POOL_CLASS': 'redis.BlockingConnectionPool',
            'CONNECTION_POOL_CLASS_KWARGS': {
                'max_connections': 50,
                'timeout': 20,
            },
        },
        'KEY_PREFIX': 'taskflow',
    }
}
```

## Caching Strategies

| Type | TTL | Example |
|------|-----|---------|
| View caching | 5 minutes | API responses |
| Query caching | 1 hour | Expensive queries |
| Low-level caching | 24 hours | User profiles |
| Session caching | 1 hour | User sessions |

## View Caching

```python
from django.views.decorators.cache import cache_page

@cache_page(60 * 5)  # Cache for 5 minutes
def task_stats(request):
    return Response(stats)
```

## Low-Level Caching

```python
from django.core.cache import cache

def get_user_profile(user_id):
    cache_key = f'user_profile:{user_id}'
    profile = cache.get(cache_key)
    if profile is None:
        profile = UserProfile.objects.get(user_id=user_id)
        cache.set(cache_key, profile, 3600)
    return profile

def invalidate_user_profile(user_id):
    cache_key = f'user_profile:{user_id}'
    cache.delete(cache_key)
```

---

# Part 23: API Performance

## Performance Bottlenecks

| Bottleneck | Cause | Solution |
|------------|-------|----------|
| Heavy Serializers | Too many fields | List vs detail serializers |
| Large Responses | Unnecessary data | `only()`, fields parameter |
| Slow Queries | Missing indexes | Add indexes, select_related |
| Large Payloads | No compression | Enable gzip compression |
| Database Load | Too many queries | Caching, query optimization |

## Serializer Optimization

```python
class TaskListSerializer(serializers.ModelSerializer):
    """Lightweight for list views"""
    class Meta:
        model = Task
        fields = ['id', 'title', 'status', 'priority', 'created_at']

class TaskDetailSerializer(serializers.ModelSerializer):
    """Full for detail views"""
    class Meta:
        model = Task
        fields = '__all__'
```

## Response Compression

```python
# Django settings
MIDDLEWARE = [
    'django.middleware.gzip.GZipMiddleware',
]
```

## Connection Pooling

```python
DATABASES = {
    'default': {
        'CONN_MAX_AGE': 600,  # Keep connections alive
        'CONN_HEALTH_CHECKS': True,
        'OPTIONS': {
            'keepalives': 1,
            'keepalives_idle': 30,
        },
    }
}
```

---

# Part 24: Automated Backend Testing

## Testing Pyramid

```
      ┌──────────┐
      │  E2E     │  Few, Slow
   ┌──┴──────────┴──┐
   │  Integration   │  Some, Medium
┌──┴────────────────┴──┐
│     Unit Tests       │  Many, Fast
└──────────────────────┘
```

## pytest Configuration

```ini
# pytest.ini
[pytest]
DJANGO_SETTINGS_MODULE = config.settings
python_files = test_*.py *_test.py
addopts = --verbose --cov=apps --cov-fail-under=70
```

## Test Fixtures

```python
@pytest.fixture
def user():
    return User.objects.create_user(email='test@example.com', password='testpass123')

@pytest.fixture
def auth_client(user):
    client = APIClient()
    client.force_authenticate(user=user)
    return client
```

## API Test Example

```python
def test_list_tasks_authenticated(auth_client, task):
    response = auth_client.get(reverse('task-list'))
    assert response.status_code == 200
    assert len(response.data['results']) >= 1

def test_create_task(auth_client, user, project):
    data = {'title': 'New Test Task', 'project': project.id}
    response = auth_client.post(reverse('task-list'), data)
    assert response.status_code == 201
```

---

# Part 25: Frontend Testing

## Testing Tools

| Tool | Purpose |
|------|---------|
| **Jest** | Test runner |
| **React Testing Library** | Component testing |
| **User Event** | User simulation |
| **MSW** | API mocking |
| **Playwright** | E2E testing |

## Component Test Example

```tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from '@/components/ui/Button';

describe('Button', () => {
    it('renders with children', () => {
        render(<Button>Click me</Button>);
        expect(screen.getByRole('button', { name: 'Click me' })).toBeInTheDocument();
    });

    it('handles click events', () => {
        const handleClick = jest.fn();
        render(<Button onClick={handleClick}>Click me</Button>);
        fireEvent.click(screen.getByRole('button'));
        expect(handleClick).toHaveBeenCalledTimes(1);
    });
});
```

## E2E Test Example

```typescript
import { test, expect } from '@playwright/test';

test('user can login', async ({ page }) => {
    await page.goto('/login');
    await page.fill('input[type="email"]', 'test@example.com');
    await page.fill('input[type="password"]', 'password123');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL('/dashboard');
});
```

---

# Part 26: API Documentation

## drf-spectacular Configuration

```python
SPECTACULAR_SETTINGS = {
    'TITLE': 'TaskFlow API',
    'DESCRIPTION': 'A modern task management platform API',
    'VERSION': '1.0.0',
    'SERVE_INCLUDE_SCHEMA': False,
    'COMPONENT_SPLIT_REQUEST': True,
}
```

## URL Configuration

```python
from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularSwaggerView,
    SpectacularRedocView,
)

urlpatterns = [
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
]
```

## Schema Annotations

```python
@extend_schema(
    summary="List tasks",
    description="Get a list of tasks with optional filtering",
    parameters=[
        OpenApiParameter(name='status', description='Filter by status', type=str),
        OpenApiParameter(name='search', description='Search in title', type=str),
    ],
    responses={200: TaskSerializer(many=True)},
)
def list(self, request):
    # ...
```

## Documentation Access
- **Swagger UI**: `/api/docs/` - Interactive API exploration
- **ReDoc**: `/api/redoc/` - Clean, readable documentation
- **Schema**: `/api/schema/` - OpenAPI JSON specification

---

# Part 27: Dockerizing Django

## Multi-Stage Dockerfile

```dockerfile
# Stage 1: Build stage
FROM python:3.12-slim AS builder
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Stage 2: Production stage
FROM python:3.12-slim
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
USER appuser
CMD ["gunicorn", "--config", "gunicorn.conf.py", "config.wsgi"]
```

## Dockerfile Layers

```
Layer 5: Application Code (changes frequently)
Layer 4: Python Dependencies (changes occasionally)
Layer 3: System Packages (rarely changes)
Layer 2: Base Python Image
Layer 1: Base OS (Alpine Linux)
```

## Gunicorn Configuration

```python
# gunicorn.conf.py
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = 'sync'
timeout = 30
max_requests = 1000
preload_app = True
```

---

# Part 28: Dockerizing Next.js

## Standalone Output

```javascript
// next.config.js
module.exports = {
    output: 'standalone',  // Self-contained deployment
    compress: true,
    poweredByHeader: false,
};
```

## Next.js Dockerfile

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

USER nextjs
EXPOSE 3000
CMD ["node", "server.js"]
```

## Image Size Comparison
- **Development**: ~1.2GB
- **Production (standalone)**: ~200MB

---

# Part 29: Docker Compose

## Service Architecture

```
        ┌─────────────┐
        │    Nginx    │
        └──────┬──────┘
               │
    ┌──────────┴──────────┐
    ▼                     ▼
┌─────────┐         ┌─────────┐
│ Next.js │         │ Django  │
│ React   │         │ DRF     │
└─────────┘         └────┬────┘
                         │
              ┌──────────┴──────────┐
              ▼                     ▼
        ┌─────────┐         ┌─────────┐
        │PostgreSQL│         │  Redis  │
        └─────────┘         └─────────┘
```

## docker-compose.yml

```yaml
version: '3.8'
services:
  backend:
    build: ./backend
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/db
      - REDIS_URL=redis://redis:6379/1
    ports:
      - "8000:8000"
    depends_on:
      - db
      - redis

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=taskflow_db
      - POSTGRES_USER=taskflow_user
      - POSTGRES_PASSWORD=taskflow_pass

  redis:
    image: redis:7-alpine

  nginx:
    image: nginx:alpine
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    ports:
      - "80:80"
```

---

# Part 30: Production Configuration

## Environment-Specific Settings

```
backend/config/settings/
├── __init__.py
├── base.py              # Shared settings
├── development.py       # Development overrides
└── production.py        # Production settings
```

## Production Security Settings

```python
# production.py
DEBUG = False
SECRET_KEY = env('SECRET_KEY')
ALLOWED_HOSTS = env.list('ALLOWED_HOSTS')

SECURE_SSL_REDIRECT = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_HTTPONLY = True
SECURE_HSTS_SECONDS = 31536000
```

## Production Logging

```python
LOGGING = {
    'version': 1,
    'handlers': {
        'file': {
            'level': 'INFO',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': '/app/logs/app.log',
            'maxBytes': 10485760,
            'backupCount': 10,
        },
    },
    'loggers': {
        'django': {
            'handlers': ['file'],
            'level': 'INFO',
        },
    },
}
```

---

# Part 31: Reverse Proxy & Networking

## Nginx Architecture

```
     Internet
         │
         ▼
    Nginx (Port 80/443)
    - SSL/TLS Termination
    - Load Balancing
    - Rate Limiting
    - Request Routing
         │
    ┌────┴────┐
    ▼         ▼
  /api/*     /*
  Backend    Frontend
  Port 8000  Port 3000
```

## SSL/TLS Configuration

```nginx
server {
    listen 443 ssl http2;
    server_name api.taskflow.com;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
}
```

## Rate Limiting

```nginx
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

location /api/ {
    limit_req zone=api_limit burst=20 nodelay;
    proxy_pass http://backend;
}
```

---

# Part 32: CI/CD

## CI/CD Pipeline

```
Push Code → Lint Check → Unit Tests → E2E Tests
→ Security Scan → Build Docker Image
→ Push to Registry → Deploy to Production
→ Health Check
```

## GitHub Actions Workflow

```yaml
name: CI/CD
on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: |
          cd backend
          pip install -r requirements/development.txt
          pytest

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        run: |
          ssh user@server "docker-compose pull && docker-compose up -d"
```

## Deployment Stages
1. **Pull Request**: Run tests, lint, build preview
2. **Merge to Main**: Build production image, deploy to staging
3. **Staging**: Full validation, manual approval
4. **Production**: Deploy with health checks, rollback if needed

---

# Part 33: Observability & Production Operations

## Observability Pillars

```
Logs - Structured JSON logs
Metrics - Request rate, error rate, response time
Traces - Request flow, service dependencies
```

## Key Metrics to Monitor

| Metric | Alert Threshold |
|--------|-----------------|
| Error Rate | > 5% over 5 minutes |
| Response Time (P95) | > 500ms |
| CPU Usage | > 80% sustained |
| Memory Usage | > 85% |
| Database Connections | > 80% of pool |

## Structured Logging

```python
import structlog
logger = structlog.get_logger()

logger.info('user_login',
    user_id=user.id,
    email=user.email,
    ip=request.ip,
    user_agent=request.META.get('HTTP_USER_AGENT')
)
```

## Sentry Integration

```python
import sentry_sdk

sentry_sdk.init(
    dsn=SENTRY_DSN,
    integrations=[DjangoIntegration()],
    traces_sample_rate=0.1,
    environment='production',
)

sentry_sdk.set_user({
    'id': user.id,
    'email': user.email,
})
```

---

# Appendices Quick Reference

## Appendix A: Deep Dives
- REST Architecture Deep Dive
- Django ORM Deep Dive
- DRF Deep Dive
- Next.js Deep Dive
- JWT Deep Dive
- Docker Deep Dive
- Testing Deep Dive

## Appendix B: Complete API Reference
- All endpoints with request/response examples
- Authentication requirements
- Error codes and messages
- Role-based permission matrix

## Appendix C: Deployment & Infrastructure
- AWS Deployment Guide
- Google Cloud Platform Guide
- Azure Deployment Guide
- SSL/TLS Configuration
- Monitoring Setup

## Appendix D: Development Environment Setup
- System Requirements
- Software Installation
- VS Code Configuration
- Project Setup Script

## Appendix E: Docker Commands & Best Practices
- Container Management
- Image Management
- Docker Compose Commands
- Dockerfile Best Practices
- Security Best Practices

## Appendix F: PostgreSQL Reference
- psql Commands
- Table Operations
- Index Management
- Query Optimization
- Backup and Recovery
- Configuration Tuning

## Appendix G: Redis Reference
- Redis Commands (Strings, Hashes, Lists, Sets, Sorted Sets)
- Pub/Sub Commands
- Lua Scripting
- Django Redis Configuration
- Caching Patterns

## Appendix H: Git Commands & Workflows
- Repository Setup
- Basic Commands
- Branch Commands
- Remote Commands
- Feature Branch Workflow
- Hotfix Workflow
- Release Workflow

## Appendix I: Security Best Practices
- Django Security Checklist
- JWT Security Best Practices
- Next.js Security Best Practices
- Docker Security Best Practices
- Database Security
- Cloud Security Best Practices

## Appendix J: Performance Optimization Guide
- Django ORM Performance
- Database Indexing Strategies
- Redis Caching
- Nginx Performance Tuning
- Frontend Performance Optimization

## Appendix K: Troubleshooting Guide
- Django Errors
- DRF Errors
- Next.js Errors
- Database Errors
- Docker Errors
- Common Issues and Solutions

## Appendix L: Glossary of Terms
- General Concepts
- Backend Terms
- Frontend Terms
- Database Terms
- DevOps Terms
- Security Terms

## Appendix M: Additional Resources
- Official Documentation
- Books
- Online Courses
- Community Forums
- Development Tools
- Deployment Platforms

## Appendix N: Django ORM Cheat Sheet
- CRUD Operations
- Field Lookups
- Relationships
- Aggregations & Annotations
- Query Optimization

## Appendix O: Frontend State Management
- Local State
- URL State
- Form State
- Server State (React Query)
- Context API
- Zustand
- Redux Toolkit

## Appendix P: Deployment Checklist
- Pre-Deployment Checklist
- Backend Deployment Checklist
- Frontend Deployment Checklist
- Infrastructure Checklist
- Monitoring Checklist
- Go-Live Checklist
- Rollback Plan

## Appendix Q: Project Templates
- Minimal DRF API Template
- Full Stack Template (Django + Next.js)
- Microservice Template
- Serverless Template

## Appendix R: Production Monitoring Dashboard
- API Monitoring Dashboard
- Database Monitoring Dashboard
- System Monitoring Dashboard
- Alert Rules Configuration
- Log Aggregation Configuration

## Appendix S: Performance Tuning Reference
- Django Performance Tuning
- PostgreSQL Tuning
- Redis Tuning
- Nginx Tuning
- Next.js Performance Tuning

## Appendix T: Common Error Messages
- Django Errors & Solutions
- DRF Errors & Solutions
- Next.js Errors & Solutions
- Database Errors & Solutions
- Docker Errors & Solutions

## Appendix U: Django & Next.js Integration Patterns
- Data Fetching Strategies
- Authentication Patterns
- Data Synchronization Patterns
- Form Handling Patterns
- File Upload Patterns
- Error Handling Patterns

## Appendix V: Environment Variables Reference
- Django Backend Variables
- Next.js Frontend Variables
- Database Variables
- Docker Variables
- CI/CD Variables

## Appendix W: Complete Technology Stack
- Backend Technologies
- Frontend Technologies
- Database Technologies
- DevOps Technologies
- CI/CD Technologies

## Appendix X: Complete Project Structure
- Project Root
- Backend Structure
- Frontend Structure
- Nginx Structure
- Observability Structure
- Documentation Structure

## Appendix Y: Debugging & Profiling Reference
- Django Debugging Tools
- Python Debugging Tools
- Database Debugging
- Next.js Debugging
- Performance Profiling
- Memory Profiling

## Appendix Z: Complete Index
- Part Index
- Technology Index
- Concept Index
- Code Pattern Index
- Error Index
- Quick Reference Cards

---

# Primers Quick Reference

## Primer 1: Python & Django Fundamentals
- Python Basics (Variables, Functions, Classes)
- Django Models, Views, Templates
- Django ORM Queries
- Django Forms and Admin

## Primer 2: JavaScript & React Fundamentals
- JavaScript ES6+ (Variables, Functions, Promises)
- React Components, Hooks
- Props and State
- Forms and Events
- Custom Hooks

## Primer 3: HTTP & REST API Fundamentals
- HTTP Methods (GET, POST, PUT, PATCH, DELETE)
- HTTP Status Codes (2xx, 3xx, 4xx, 5xx)
- REST Principles (6 Constraints)
- Resource-Oriented URLs
- API Versioning

## Primer 4: Docker & Containerization
- Docker Components (Images, Containers, Volumes)
- Dockerfile Instructions
- Multi-Stage Builds
- Docker Compose
- Container Orchestration Concepts

## Primer 5: Git & Version Control
- Git Architecture
- Basic Commands (add, commit, status, log)
- Branch Commands (branch, checkout, merge, rebase)
- Remote Commands (remote, fetch, pull, push)
- Git Workflows (Feature Branch, Hotfix, Release)

## Primer 6: SQL & Database Fundamentals
- PostgreSQL Commands (psql)
- SQL Fundamentals (SELECT, INSERT, UPDATE, DELETE)
- Advanced SQL (Aggregations, Window Functions)
- Database Indexes
- Query Analysis and Optimization

## Primer 7: Testing Fundamentals
- Testing Pyramid (Unit, Integration, E2E)
- Backend Testing with pytest
- Frontend Testing with Jest
- E2E Tests with Playwright
- Mocking (MSW, React Hooks)

## Primer 8: Authentication & Authorization
- Authentication vs Authorization
- JWT Structure and Lifecycle
- OAuth 2.0 Flow
- Authorization Models (ACL, RBAC, ABAC)
- Security Attacks and Prevention

## Primer 9: Docker & Container Orchestration
- Docker Fundamentals (Review)
- Docker Compose (Review)
- Container Orchestration (Kubernetes, ECS)
- Kubernetes Resources (Pod, Deployment, Service)
- Docker Best Practices

## Primer 10: Development Tools & Workflow
- VS Code Setup and Extensions
- Terminal & Shell Setup
- Git Workflows (Feature Branch, Hotfix, Release)
- Package Managers (pip, npm)
- Debugging Workflow (Backend, Frontend)

---

## Quick Command Reference

### Django
```bash
python manage.py runserver
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
python manage.py shell
python manage.py test
```

### Next.js
```bash
npm run dev
npm run build
npm start
npm run test
npx playwright test
```

### Docker
```bash
docker build -t image:tag .
docker run -d --name container image
docker ps
docker logs container
docker exec -it container bash
docker-compose up -d
docker-compose down
docker-compose logs -f
```

### Git
```bash
git status
git add .
git commit -m "message"
git push origin main
git pull origin main
git checkout -b feature/branch
git merge feature/branch
git branch -d feature/branch
```

### PostgreSQL
```bash
psql -U user -d database
\l
\dt
\d table
\q
```

### Redis
```bash
redis-cli
SET key value
GET key
KEYS *
FLUSHALL
```

---

*These notes accompany the Django REST Framework & Next.js 16: From Scratch to Production masterclass.*
