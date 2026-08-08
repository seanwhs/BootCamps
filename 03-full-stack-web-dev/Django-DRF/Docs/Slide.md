# Django REST Framework & Next.js 16: Complete Slide Deck Outline

## From Scratch to Production — Comprehensive Teaching Series

---

## Part 0: Introduction & Course Overview

### Slide 0.1: Title Slide
- **Title:** Django REST Framework & Next.js 16: From Scratch to Production
- **Subtitle:** Building Modern Decoupled Full-Stack Applications
- **Author/Instructor Name**
- **Date/Location**

### Slide 0.2: The Central Architecture
- **Visual:** Diagram showing the complete architecture stack
  - Browser → Next.js 16 (React 19 / App Router) → HTTP/JSON → Django REST Framework API → PostgreSQL + Redis
- **Key Message:** Clean client-server boundary
- **Layers:** Frontend (Next.js) ↔ Contract (API) ↔ Backend (Django)

### Slide 0.3: What You'll Build
- **Backend:**
  - Django 6.x / DRF REST API
  - User management + JWT Authentication
  - Role-based permissions
  - Projects, Tasks, Comments
  - Search, Filtering, Pagination
  - PostgreSQL + Redis Caching
  - OpenAPI Documentation
- **Frontend:**
  - Next.js 16 + React 19 + App Router
  - Public area (Landing, Pricing, Login, Register)
  - Authenticated area (Dashboard, Projects, Tasks)
  - Search, Filtering, Pagination
  - Responsive UI with Tailwind CSS

### Slide 0.4: Technology Stack (Visual Summary)

| Layer | Technology |
|-------|------------|
| Language | Python 3.12+ |
| Backend Framework | Django 6.x |
| API Framework | Django REST Framework 3.15.x |
| Authentication | JWT / djangorestframework-simplejwt |
| Database | PostgreSQL 15+ |
| Cache | Redis 7+ |
| Frontend | Next.js 16 |
| UI | React 19 |
| Styling | Tailwind CSS |
| API Documentation | OpenAPI / drf-spectacular |
| Backend Testing | pytest / pytest-django |
| Application Server | Gunicorn |
| Reverse Proxy | Nginx |
| Containers | Docker / Docker Compose |
| CI/CD | GitHub Actions |

### Slide 0.5: Prerequisites
- **Python**
  - Variables and data types, Functions, Classes
  - Exceptions, Modules and packages, Virtual environments
- **Django**
  - Projects and applications, URL routing, Views, Models
  - Migrations, Django ORM, Basic authentication
- **Web Development**
  - HTML, CSS, HTTP fundamentals, JSON
  - Basic JavaScript, Basic Git

### Slide 0.6: Learning Journey Roadmap

```
Phase 1: REST API & Next.js Foundations (Parts 0-7)
    ↓
Phase 2: Advanced DRF & Next.js Data Flow (Parts 8-13)
    ↓
Phase 3: Authentication, Authorization & Security (Parts 14-20)
    ↓
Phase 4: Performance, Testing, Documentation & Production (Parts 21-33)
    ↓
Appendices (A-Z) + Primers (1-10)
```

### Slide 0.7: Course Philosophy
- **Separation of Concerns:**
  - Backend: Data, Business Rules, Authentication, Authorization, Validation, API Contracts
  - Frontend: Routing, UI, User Interaction, Form State, Client Experience, Rendering
  - API: The contract between the two systems
- **Key Principle:** "Django owns the data and business rules. Next.js delivers the frontend experience."

---

## Phase 1: REST API & Next.js Foundations

---

### Part 1: REST Architecture & HTTP Fundamentals

#### Slide 1.1: Introduction to REST
- **What is an API?** Set of rules allowing software applications to communicate
- **REST Principles (6 Constraints):**
  1. Client-Server Separation
  2. Statelessness
  3. Cacheability
  4. Uniform Interface
  5. Layered System
  6. Code on Demand (optional)
- **Resource-Oriented Design:** Everything is a noun (users, projects, tasks)

#### Slide 1.2: HTTP Methods (Verbs)

| Method | Purpose | Idempotent? | Safe? | Body |
|--------|---------|-------------|-------|------|
| GET | Retrieve data | Yes | Yes | No |
| POST | Create data | No | No | Yes |
| PUT | Replace data | Yes | No | Yes |
| PATCH | Partial update | No | No | Yes |
| DELETE | Remove data | Yes | No | No |

#### Slide 1.3: HTTP Status Codes
- **2xx Success:** 200 OK, 201 Created, 204 No Content
- **3xx Redirection:** 301 Moved Permanently, 304 Not Modified
- **4xx Client Errors:** 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 422 Unprocessable Entity, 429 Too Many Requests
- **5xx Server Errors:** 500 Internal Server Error, 502 Bad Gateway, 503 Service Unavailable

#### Slide 1.4: JSON & API Design
- **JSON Structure:** Objects, Arrays, Nested structures
- **Good URL Design:**
  ```
  GET    /api/users              - List users
  POST   /api/users              - Create user
  GET    /api/users/{id}         - Get user
  PUT    /api/users/{id}         - Replace user
  PATCH  /api/users/{id}         - Update user
  DELETE /api/users/{id}         - Delete user
  ```
- **Poor URL Design (Avoid):** `/api/getUser?id=1`, `/api/createUser`

---

### Part 2: Django 6 Backend Foundations

#### Slide 2.1: Django Project Setup
- **Virtual Environment:** `python -m venv venv`
- **Dependencies:** Django, psycopg2-binary, django-environ, python-dotenv
- **Project Creation:** `django-admin startproject config .`

#### Slide 2.2: Django Settings with Environment Variables
```python
# settings.py
import environ
env = environ.Env()
SECRET_KEY = env('SECRET_KEY')
DEBUG = env('DEBUG', default=False)
DATABASE_URL = env('DATABASE_URL')
```

#### Slide 2.3: Data Model (Visual)

```
User (Custom Model)
 ├── Projects (created_by)
 │    └── Tasks
 │         └── Comments
 └── Tasks (assigned_to)
      └── Comments
```

#### Slide 2.4: Django Models Example

```python
class Task(models.Model):
    class Status(models.TextChoices):
        TODO = 'todo', 'To Do'
        IN_PROGRESS = 'in_progress', 'In Progress'
        DONE = 'done', 'Done'
    
    title = models.CharField(max_length=255)
    project = models.ForeignKey('projects.Project', on_delete=models.CASCADE)
    created_by = models.ForeignKey('users.User', on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        indexes = [
            models.Index(fields=['project', 'status']),
        ]
```

#### Slide 2.5: Relationships Summary
- **User → Projects:** One-to-Many (ForeignKey)
- **Project → Tasks:** One-to-Many (ForeignKey)
- **Task → Comments:** One-to-Many (ForeignKey)
- **User → Tasks:** Two relationships: created_by and assigned_to

#### Slide 2.6: Django Migrations Workflow
```bash
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
python manage.py loaddata fixtures/initial_data.json
```

---

### Part 3: DRF Serializers

#### Slide 3.1: What is a Serializer?
- Converts Django models to JSON (serialization)
- Converts JSON to Python objects (deserialization)
- Validates incoming data
- Handles nested relationships

#### Slide 3.2: Types of Serializers

| Type | Description | Use Case |
|------|-------------|----------|
| `Serializer` | Manual field definitions | Custom data structures |
| `ModelSerializer` | Auto-generated from model | Most CRUD operations |
| `HyperlinkedModelSerializer` | Hyperlinks for relationships | RESTful APIs with HATEOAS |

#### Slide 3.3: ModelSerializer Example

```python
class TaskSerializer(serializers.ModelSerializer):
    project_name = serializers.CharField(source='project.name', read_only=True)
    
    class Meta:
        model = Task
        fields = ['id', 'title', 'description', 'status', 'project', 'project_name']
        read_only_fields = ['created_at', 'updated_at']
    
    def validate_title(self, value):
        if len(value) < 3:
            raise serializers.ValidationError("Title too short")
        return value
```

#### Slide 3.4: Validation Layers
1. **Field-level:** `validate_<field_name>()`
2. **Object-level:** `validate()`
3. **Model-level:** Model validation (Django)

#### Slide 3.5: Nested Serializers & Relationships
```python
class ProjectSerializer(serializers.ModelSerializer):
    tasks = TaskSerializer(many=True, read_only=True)
    
    class Meta:
        model = Project
        fields = ['id', 'name', 'tasks']
```

---

### Part 4: Building API Views

#### Slide 4.1: View Types in DRF

```
Function-Based Views (@api_view)
         ↓
Class-Based Views (APIView)
         ↓
Generic Views (ListCreateAPIView, etc.)
         ↓
ViewSets (ModelViewSet)
         ↓
Routers (DefaultRouter)
```

#### Slide 4.2: CRUD Endpoint Table

| Operation | HTTP Method | URL | Request Body | Response |
|-----------|-------------|-----|--------------|----------|
| **Create** | POST | `/api/tasks/` | Task data | 201 Created |
| **Read (List)** | GET | `/api/tasks/` | None | 200 OK |
| **Read (Detail)** | GET | `/api/tasks/1/` | None | 200 OK |
| **Update (Full)** | PUT | `/api/tasks/1/` | Complete task | 200 OK |
| **Update (Partial)** | PATCH | `/api/tasks/1/` | Partial data | 200 OK |
| **Delete** | DELETE | `/api/tasks/1/` | None | 204 No Content |

#### Slide 4.3: APIView Example
```python
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

class TaskList(APIView):
    def get(self, request):
        tasks = Task.objects.all()
        serializer = TaskSerializer(tasks, many=True)
        return Response(serializer.data)
    
    def post(self, request):
        serializer = TaskSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
```

#### Slide 4.4: URL Routing Structure
```python
# api/urls.py
urlpatterns = [
    path('tasks/', views.TaskList.as_view()),
    path('tasks/<int:pk>/', views.TaskDetail.as_view()),
]
```

---

### Part 5: Next.js 16 Foundations

#### Slide 5.1: Why Next.js?
- **Server Components** reduce client-side JavaScript
- **App Router** provides powerful routing and layouts
- **React Server Components** enable efficient data fetching
- **Built-in optimization** for images, fonts, scripts
- **Excellent developer experience** with Fast Refresh

#### Slide 5.2: App Router Structure

```
app/
├── (auth)/              # Route group (doesn't affect URL)
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

#### Slide 5.3: Server vs Client Components

| Feature | Server Components (Default) | Client Components ('use client') |
|---------|-----------------------------|----------------------------------|
| Rendering | Server | Client |
| Async/Await | ✅ Yes | ❌ No |
| React Hooks | ❌ No | ✅ Yes |
| Browser APIs | ❌ No | ✅ Yes |
| Event Handlers | ❌ No | ✅ Yes |
| SEO | ✅ Excellent | ❌ Limited |

#### Slide 5.4: Server Component Example
```tsx
// Server Component - fetches data on the server
export default async function TaskList() {
    const res = await fetch('http://localhost:8000/api/v1/tasks/');
    const tasks = await res.json();
    return <div>{/* Render tasks */}</div>;
}
```

#### Slide 5.5: Client Component Example
```tsx
'use client';

import { useState } from 'react';

export default function Counter() {
    const [count, setCount] = useState(0);
    return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

#### Slide 5.6: Tailwind CSS Setup
- **Utility-first CSS** framework
- **Configuration:** `tailwind.config.js`
- **Global styles:** `globals.css`
- **Component patterns:** `cn()` utility with clsx + tailwind-merge

---

### Part 6: Connecting Next.js to DRF

#### Slide 6.1: Data Flow Overview

```
Next.js Server Component
     ↓
fetch() → Django API
     ↓
Data → Server-side rendering
     ↓
HTML sent to client
```

#### Slide 6.2: API Client Setup

```typescript
// lib/api/client.ts
const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api/v1';

export async function get<T>(endpoint: string): Promise<T> {
    const response = await fetch(`${API_URL}${endpoint}`, {
        headers: {
            'Content-Type': 'application/json',
        },
    });
    if (!response.ok) {
        throw new Error(`API Error: ${response.status}`);
    }
    return response.json();
}
```

#### Slide 6.3: Data Fetching in Server Components
```tsx
// app/(dashboard)/projects/page.tsx
import { get } from '@/lib/api/client';
import { ProjectList } from './components/ProjectList';

export default async function ProjectsPage() {
    const projects = await get<Project[]>('/projects/');
    return <ProjectList initialProjects={projects} />;
}
```

#### Slide 6.4: Client-Side Fetching with React Query
```tsx
'use client';

import { useQuery } from '@tanstack/react-query';

export function TaskList() {
    const { data, isLoading } = useQuery({
        queryKey: ['tasks'],
        queryFn: () => get<Task[]>('/tasks/'),
    });
    
    if (isLoading) return <LoadingSpinner />;
    return <div>{/* Render tasks */}</div>;
}
```

#### Slide 6.5: Form Handling Example
```tsx
'use client';

export function TaskForm() {
    const [loading, setLoading] = useState(false);
    const [errors, setErrors] = useState({});
    
    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        const response = await post('/tasks/', formData);
        if (response.error) {
            setErrors(response.error);
        } else {
            router.push('/tasks');
        }
        setLoading(false);
    };
    // ...
}
```

---

### Part 7: CRUD Operations Across the Stack

#### Slide 7.1: Complete CRUD Endpoint Map

| Resource | Create | Read (List) | Read (Detail) | Update | Delete |
|----------|--------|-------------|---------------|--------|--------|
| Users | POST /users/ | GET /users/ | GET /users/{id}/ | PUT/PATCH /users/{id}/ | DELETE /users/{id}/ |
| Projects | POST /projects/ | GET /projects/ | GET /projects/{id}/ | PUT/PATCH /projects/{id}/ | DELETE /projects/{id}/ |
| Tasks | POST /tasks/ | GET /tasks/ | GET /tasks/{id}/ | PUT/PATCH /tasks/{id}/ | DELETE /tasks/{id}/ |
| Comments | POST /comments/ | GET /comments/ | GET /comments/{id}/ | PUT/PATCH /comments/{id}/ | DELETE /comments/{id}/ |

#### Slide 7.2: CRUD Data Flow Diagram

```
User Action (click, submit)
     ↓
Client Component
     ↓
API Request (fetch)
     ↓
Django API
     ↓
Database Update
     ↓
Response Returned
     ↓
Client Updates UI
     ↓
Server Revalidates
```

#### Slide 7.3: Toast Notifications & Confirmation Modals

- **Toast Notifications:** User feedback for all operations
- **Confirmation Modals:** Prevent accidental deletions
- **Loading States:** Visual feedback during async operations
- **Error Handling:** Display validation errors from API

#### Slide 7.4: Phase 1 Outcome Check
- ✅ Django REST API with CRUD for all resources
- ✅ Next.js frontend with App Router
- ✅ Server and Client Components
- ✅ Data fetching and mutations
- ✅ Forms, validation, toast notifications

---

## Phase 2: Advanced DRF & Next.js Data Flow

---

### Part 8: Generic Views, ViewSets & Routers

#### Slide 8.1: DRF View Evolution

```
Function-Based Views (@api_view)
         ↓
Class-Based Views (APIView)
         ↓
Generic Views (ListCreateAPIView, etc.)
         ↓
ViewSets (ModelViewSet)
         ↓
Routers (DefaultRouter)
```

#### Slide 8.2: Generic Views Comparison

| Generic View | Methods | Use Case |
|--------------|---------|----------|
| `ListAPIView` | GET | List resources |
| `CreateAPIView` | POST | Create resources |
| `RetrieveAPIView` | GET | Detail view |
| `UpdateAPIView` | PUT/PATCH | Update resources |
| `DestroyAPIView` | DELETE | Delete resources |
| `ListCreateAPIView` | GET, POST | List + Create |
| `RetrieveUpdateDestroyAPIView` | GET, PUT, PATCH, DELETE | Full CRUD |

#### Slide 8.3: ViewSet Example
```python
from rest_framework import viewsets

class TaskViewSet(viewsets.ModelViewSet):
    """
    Automatically handles:
    - GET /tasks/           -> list()
    - POST /tasks/          -> create()
    - GET /tasks/{id}/      -> retrieve()
    - PUT /tasks/{id}/      -> update()
    - PATCH /tasks/{id}/    -> partial_update()
    - DELETE /tasks/{id}/   -> destroy()
    """
    queryset = Task.objects.all()
    serializer_class = TaskSerializer
```

#### Slide 8.4: Custom Actions with @action
```python
from rest_framework.decorators import action

class TaskViewSet(viewsets.ModelViewSet):
    @action(detail=True, methods=['post'])
    def complete(self, request, pk=None):
        task = self.get_object()
        task.status = 'done'
        task.save()
        return Response({'status': 'completed'})
    
    @action(detail=False, methods=['get'])
    def stats(self, request):
        stats = {
            'total': Task.objects.count(),
            'completed': Task.objects.filter(status='done').count()
        }
        return Response(stats)
```

#### Slide 8.5: Router Configuration
```python
from rest_framework.routers import DefaultRouter

router = DefaultRouter()
router.register(r'tasks', TaskViewSet, basename='task')
router.register(r'projects', ProjectViewSet, basename='project')

urlpatterns = router.urls

# Automatically creates:
# ^tasks/$                    [name='task-list']
# ^tasks/{id}/$               [name='task-detail']
# ^tasks/{id}/complete/$      [name='task-complete']
# ^tasks/stats/$              [name='task-stats']
```

---

### Part 9: Advanced Querying

#### Slide 9.1: django-filter Capabilities
- **Filtering:** Exact matches, range filters, date filters
- **Search:** Full-text search across multiple fields
- **Ordering:** Sort by any field
- **Custom filters:** Complex business logic
- **Relationship filtering:** Filter on related model fields

#### Slide 9.2: FilterSet Example
```python
class TaskFilter(FilterSet):
    status = filters.CharFilter(field_name='status')
    priority = filters.ChoiceFilter(choices=Task.Priority.choices)
    created_after = filters.DateTimeFilter(field_name='created_at', lookup_expr='gte')
    search = filters.CharFilter(method='filter_search')
    
    class Meta:
        model = Task
        fields = ['status', 'priority', 'project', 'assigned_to']
```

#### Slide 9.3: Query Parameter Examples

```
# Filter by status
GET /api/tasks/?status=in_progress

# Filter by priority
GET /api/tasks/?priority=high

# Multiple filters
GET /api/tasks/?status=done&priority=high

# Search in title and description
GET /api/tasks/?search=api

# Date filters
GET /api/tasks/?created_after=2026-01-15T00:00:00Z

# Relationship filtering
GET /api/tasks/?project_name=masterclass

# Ordering
GET /api/tasks/?ordering=-created_at

# Combined
GET /api/tasks/?status=done&search=api&ordering=-created_at&page=2
```

#### Slide 9.4: Search & Ordering
```python
class TaskViewSet(viewsets.ModelViewSet):
    filter_backends = [
        DjangoFilterBackend,
        filters.SearchFilter,
        filters.OrderingFilter,
    ]
    
    filterset_class = TaskFilter
    search_fields = ['title', 'description']
    ordering_fields = ['created_at', 'priority', 'status']
    ordering = ['-created_at']
```

---

### Part 10: Pagination

#### Slide 10.1: Pagination Strategies

| Strategy | URL Pattern | Best For |
|----------|-------------|----------|
| **Page Number** | `?page=2&page_size=20` | Most use cases, page jumping |
| **Limit Offset** | `?limit=20&offset=40` | Position-based navigation |
| **Cursor** | `?cursor=encoded_string` | Infinite scrolling, consistency |

#### Slide 10.2: Pagination Response Format
```json
{
    "count": 100,
    "next": "http://api.taskflow.com/api/v1/tasks/?page=3",
    "previous": "http://api.taskflow.com/api/v1/tasks/?page=1",
    "page_size": 20,
    "current_page": 2,
    "total_pages": 5,
    "results": [...]
}
```

#### Slide 10.3: Custom Pagination Class
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

#### Slide 10.4: Frontend Pagination UI
- **Page numbers** with ellipsis for large datasets
- **Previous/Next** navigation buttons
- **Page size selector** (10, 20, 50, 100)
- **Item count display** ("Showing 1-20 of 100")

---

### Part 11: Next.js Routing & Navigation

#### Slide 11.1: App Router Architecture

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
│   │   ├── [id]/
│   │   │   ├── page.tsx → /projects/123
│   │   │   └── edit/
│   │   │       └── page.tsx → /projects/123/edit
│   │   └── create/
│   │       └── page.tsx → /projects/create
│   └── tasks/
│       ├── page.tsx     → /tasks
│       └── [id]/
│           └── page.tsx → /tasks/456
├── layout.tsx           # Root layout
├── page.tsx             → /
├── loading.tsx          # Global loading
└── error.tsx            # Global error
```

#### Slide 11.2: Route Groups & Layouts
- **Route groups `(folder)`** organize routes without affecting URL
- **Layouts** wrap pages and persist across navigation
- **Nested layouts** for different sections of the app
- **Loading UI** `loading.tsx` shows while pages load
- **Error Boundaries** `error.tsx` catch errors in route segment

#### Slide 11.3: Dynamic Routes
```tsx
// app/projects/[id]/page.tsx
export default async function ProjectPage({ params }: { params: { id: string } }) {
    const project = await getProject(params.id);
    return <ProjectDetail project={project} />;
}

// Link to dynamic route
<Link href={`/projects/${project.id}`}>View Project</Link>
```

#### Slide 11.4: Active Navigation
```tsx
'use client';

const pathname = usePathname();
const isActive = pathname === href || pathname?.startsWith(href + '/');

<Link href={href} className={isActive ? 'active' : ''}>
    {name}
</Link>
```

---

### Part 12: Frontend Data Architecture

#### Slide 12.1: Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        User Interface                       │
└───────────────────────────────┬─────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                      Client Components                       │
└───────────────────────────────┬─────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                    Data Layer (Hooks)                        │
└───────────────────────────────┬─────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                     Cache Layer (React Query)                │
└───────────────────────────────┬─────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                       API Client                             │
└─────────────────────────────────────────────────────────────┘
```

#### Slide 12.2: React Query Setup
```tsx
// QueryProvider.tsx
export function QueryProvider({ children }) {
    const queryClient = new QueryClient({
        defaultOptions: {
            queries: {
                staleTime: 60 * 1000, // 1 minute
                gcTime: 5 * 60 * 1000, // 5 minutes
                retry: 1,
                refetchOnWindowFocus: false,
            },
        },
    });
    return <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>;
}
```

#### Slide 12.3: Data Fetching with React Query
```tsx
// useTasks hook
export function useTasks(filters = {}) {
    return useQuery({
        queryKey: ['tasks', filters],
        queryFn: () => get<Task[]>(ENDPOINTS.tasks.list, filters),
        staleTime: 60 * 1000,
    });
}

// Usage in component
function TaskList() {
    const { data: tasks, isLoading, error } = useTasks({ status: 'todo' });
    // ...
}
```

#### Slide 12.4: Mutations & Optimistic Updates
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

#### Slide 12.5: Cache Invalidation Strategies
1. **Time-based:** `staleTime` configuration
2. **On-demand:** `invalidateQueries()` after mutations
3. **Navigation-based:** `router.refresh()` on route change
4. **Optimistic:** Update UI immediately, revalidate in background

---

### Part 13: Searchable Data Interfaces

#### Slide 13.1: URL State Management
```
URL: /tasks?search=api&status=in_progress&priority=high&page=2&sort=-created_at
```

**Benefits:**
- Shareable links
- Bookmarkable views
- Browser navigation works naturally
- Server-side state availability

#### Slide 13.2: useUrlState Hook
```tsx
export function useUrlState<T>() {
    const router = useRouter();
    const searchParams = useSearchParams();
    
    const state = useMemo(() => {
        const params: Record<string, any> = {};
        searchParams.forEach((value, key) => {
            params[key] = value;
        });
        return params as T;
    }, [searchParams]);
    
    const updateState = useCallback((updates: Partial<T>) => {
        const params = new URLSearchParams(searchParams.toString());
        Object.entries(updates).forEach(([key, value]) => {
            if (value) params.set(key, String(value));
            else params.delete(key);
        });
        router.push(`?${params.toString()}`);
    }, [router, searchParams]);
    
    return { state, updateState };
}
```

#### Slide 13.3: Data Table Components
- **DataTable:** Reusable table with sorting
- **DataTableHeader:** Sortable headers
- **DataTableToolbar:** Search + filters
- **Pagination:** Page navigation
- **PageSizeSelector:** Items per page

#### Slide 13.4: Combined Filtering Flow

```
User Action (search, filter, sort, page change)
     ↓
Update URL State
     ↓
useUrlState triggers re-render
     ↓
Query parameters updated
     ↓
React Query fetches new data
     ↓
Data Table re-renders
```

#### Slide 13.5: Phase 2 Outcome Check
- ✅ Generic views and ViewSets
- ✅ Advanced filtering with django-filter
- ✅ Pagination (custom classes, frontend controls)
- ✅ Next.js routing and navigation
- ✅ Frontend data architecture with React Query
- ✅ Searchable data interfaces with URL state

---

## Phase 3: Authentication, Authorization & Application Security

---

### Part 14: Authentication Architecture

#### Slide 14.1: Authentication vs Authorization

| Concept | Definition | Questions |
|---------|------------|-----------|
| **Authentication** | Verifying who a user is | "Are you who you say you are?" |
| **Authorization** | What a user can do | "Are you allowed to do this?" |
| **Identification** | Declaring who a user is | "Who are you?" |

#### Slide 14.2: JWT Architecture

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.
eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.
SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c

Header: {"alg": "HS256", "typ": "JWT"}
Payload: {"sub": "123", "name": "John Doe", "iat": 1516239022, "exp": 1516239322}
Signature: HMACSHA256(header + "." + payload, secret)
```

#### Slide 14.3: Token Lifecycle

```
1. User logs in
   ↓
2. Server validates credentials
   ↓
3. Server generates access + refresh tokens
   ↓
4. Client stores tokens
   ↓
5. Client sends access token with API requests
   ↓
6. Server validates token before processing
   ↓
7. Token expires → Client uses refresh token
   ↓
8. Server issues new access token
```

#### Slide 14.4: SimpleJWT Configuration

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

#### Slide 14.5: Authentication Endpoints
- `POST /api/v1/token/` - Obtain token pair
- `POST /api/v1/token/refresh/` - Refresh access token
- `POST /api/v1/token/verify/` - Verify token validity
- `POST /api/v1/users/register/` - User registration

---

### Part 15: JWT with SimpleJWT

#### Slide 15.1: Token Management (Frontend)

```typescript
// lib/auth/token.ts
let accessToken: string | null = null;

export function getAccessToken(): string | null {
    if (accessToken) return accessToken;
    return localStorage.getItem('access_token');
}

export function setTokens(access: string, refresh: string) {
    accessToken = access;
    localStorage.setItem('access_token', access);
    localStorage.setItem('refresh_token', refresh);
}

export function clearTokens() {
    accessToken = null;
    localStorage.removeItem('access_token');
    localStorage.removeItem('refresh_token');
}
```

#### Slide 15.2: Auth Context
```tsx
'use client';

export function AuthProvider({ children }) {
    const [user, setUser] = useState(null);
    
    const login = async (email: string, password: string) => {
        const response = await post('/token/', { email, password });
        setTokens(response.access, response.refresh);
        setUser(response.user);
    };
    
    const logout = () => {
        clearTokens();
        setUser(null);
        router.push('/login');
    };
    
    // ...
}
```

#### Slide 15.3: API Client with Token Interceptor
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

#### Slide 15.4: Route Protection (Middleware)

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

### Part 16: DRF Permissions

#### Slide 16.1: Permission System Overview
- **View-level permissions:** `has_permission()`
- **Object-level permissions:** `has_object_permission()`
- **Global permissions:** Settings `DEFAULT_PERMISSION_CLASSES`
- **Custom permissions:** Extend `BasePermission`

#### Slide 16.2: Permission Flow

```
1. Request arrives at view
   ↓
2. `has_permission` called
   - Checks authentication
   - Checks role-based permissions
   ↓
3. If `has_permission` returns True
   ↓
4. `has_object_permission` called
   - Checks ownership
   - Checks object-specific rules
   ↓
5. If both return True → Access granted
```

#### Slide 16.3: Custom Permission Example
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

#### Slide 16.4: Applying Permissions to Viewsets
```python
class ProjectViewSet(viewsets.ModelViewSet):
    def get_permissions(self):
        if self.action == 'create':
            return [IsAuthenticated()]
        elif self.action == 'destroy':
            return [IsAuthenticated(), IsProjectOwner()]
        return [IsAuthenticated(), HasProjectAccess()]
```

---

### Part 17: Role-Based Access Control

#### Slide 17.1: Role Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│  ADMIN: All permissions                                    │
│    ├─ Manage users (create, edit, delete, assign roles)     │
│    ├─ Manage all projects and tasks                         │
│    └─ Access all settings                                   │
├─────────────────────────────────────────────────────────────┤
│  MANAGER: Project management                               │
│    ├─ Manage users (view only)                              │
│    ├─ Create, edit, delete projects                         │
│    ├─ Assign tasks to members                               │
│    └─ Access project settings                               │
├─────────────────────────────────────────────────────────────┤
│  MEMBER: Task execution                                    │
│    ├─ View projects they're assigned to                     │
│    ├─ Update assigned tasks                                 │
│    └─ Add comments                                          │
├─────────────────────────────────────────────────────────────┤
│  VIEWER: Read-only                                          │
│    ├─ View projects they're assigned to                     │
│    └─ View tasks and comments                               │
└─────────────────────────────────────────────────────────────┘
```

#### Slide 17.2: Role Methods in User Model
```python
class User(AbstractUser):
    @property
    def is_admin(self):
        return self.role == self.Roles.ADMIN or self.is_superuser
    
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

#### Slide 17.3: Role-Based UI (Frontend)

```tsx
// RoleGuard component
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

// Navigation items based on role
const navigation = [
    { name: 'Dashboard', href: '/dashboard' },
    { name: 'Projects', href: '/projects' },
    { name: 'Tasks', href: '/tasks' },
    ...(isAdmin ? [{ name: 'Admin', href: '/admin' }] : []),
    ...(isManagerOrHigher ? [{ name: 'Users', href: '/users' }] : []),
    { name: 'Settings', href: '/settings' },
];
```

---

### Part 18: Next.js Authentication

#### Slide 18.1: Authentication Layers in Next.js

1. **Middleware** - Protects routes at the request level
2. **Server Components** - Authenticates on the server
3. **Client Components** - Manages client-side authentication state
4. **API Routes** - Handles authentication-related API calls

#### Slide 18.2: Server-Side Auth Utilities
```typescript
// lib/auth/server-auth.ts
'use server';

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

#### Slide 18.3: Server Component with Auth
```tsx
// app/(dashboard)/dashboard/page.tsx
import { requireAuth } from '@/lib/auth/server-auth';

export default async function DashboardPage() {
    const user = await requireAuth();
    return <div>Welcome, {user.email}!</div>;
}
```

---

### Part 19: Next.js Request Interception

#### Slide 19.1: Request Interception Flow

```
1. Client makes request
     ↓
2. Request passes through interceptors
     ├── Auth Interceptor: Adds token
     ├── CSRF Interceptor: Adds CSRF token
     └── Logger Interceptor: Logs request
     ↓
3. Request sent to server
     ↓
4. Response received
     ↓
5. Response passes through interceptors
     ├── Error Interceptor: Handles 401/403
     ├── Refresh Interceptor: Refreshes token if needed
     └── Logger Interceptor: Logs response
     ↓
6. Response returned to client
```

#### Slide 19.2: API Interceptor Pattern
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

### Part 20: API Security

#### Slide 20.1: Security Layers

```
Network Layer:
├── HTTPS (production)
├── CORS Configuration
└── Rate Limiting

Application Layer:
├── JWT Authentication
├── Permission Checks
├── Input Validation
└── SQL Injection Protection

Data Layer:
├── Encryption (passwords)
├── Data Sanitization
└── Audit Logging

Infrastructure Layer:
├── Environment Variables
├── Secure Headers
└── Error Handling
```

#### Slide 20.2: Rate Limiting

```python
# django-ratelimit
from django_ratelimit.decorators import ratelimit

@ratelimit(key='ip', rate='10/m')
def login_view(request):
    pass  # 10 requests per minute

@ratelimit(key='user', rate='100/h')
def api_view(request):
    pass  # 100 requests per hour
```

| Endpoint | Rate Limit |
|----------|------------|
| Login | 10 per minute |
| Registration | 5 per minute |
| General API | 100 per hour |
| Token Refresh | 20 per hour |

#### Slide 20.3: CORS Configuration
```python
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "https://app.taskflow.com",
]
CORS_ALLOW_CREDENTIALS = True
CORS_ALLOW_METHODS = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS']
CORS_ALLOW_HEADERS = ['authorization', 'content-type']
```

#### Slide 20.4: Security Headers

| Header | Value | Purpose |
|--------|-------|---------|
| `Strict-Transport-Security` | `max-age=31536000` | Enforce HTTPS |
| `X-Frame-Options` | `DENY` | Prevent clickjacking |
| `X-Content-Type-Options` | `nosniff` | Prevent MIME sniffing |
| `X-XSS-Protection` | `1; mode=block` | XSS protection |
| `Content-Security-Policy` | `default-src 'self'` | Resource restrictions |

#### Slide 20.5: Phase 3 Outcome Check
- ✅ JWT authentication with SimpleJWT
- ✅ User registration and login
- ✅ Role-based permissions
- ✅ Custom permission classes
- ✅ Object-level permissions
- ✅ Next.js authentication
- ✅ Request interception
- ✅ API security (rate limiting, CORS, headers)

---

## Phase 4: Performance, Testing, Documentation & Production

---

### Part 21: Django ORM Performance

#### Slide 21.1: The N+1 Query Problem

```python
# Problem: N+1 queries
tasks = Task.objects.all()  # 1 query
for task in tasks:
    print(task.project.name)  # N queries (one per task)

# Solution: select_related (1 query)
tasks = Task.objects.select_related('project').all()
for task in tasks:
    print(task.project.name)  # No additional query

# Solution: prefetch_related (2 queries)
tasks = Task.objects.prefetch_related('comments').all()
for task in tasks:
    print(task.comments.count())  # Uses prefetched data
```

#### Slide 21.2: Query Optimization Patterns

| Method | Use Case | Example |
|--------|----------|---------|
| `select_related` | ForeignKey, OneToOne | `select_related('project', 'assigned_to')` |
| `prefetch_related` | ManyToMany, reverse FK | `prefetch_related('comments', 'tags')` |
| `only` | Fetch specific fields | `only('title', 'status')` |
| `defer` | Exclude large fields | `defer('description')` |
| `values` | Get dictionary of data | `values('id', 'title')` |
| `values_list` | Get tuple of data | `values_list('id', flat=True)` |

#### Slide 21.3: Database Indexes

```python
class Task(models.Model):
    class Meta:
        indexes = [
            models.Index(fields=['status']),
            models.Index(fields=['project', 'status']),
            models.Index(fields=['assigned_to', 'status']),
            models.Index(fields=['-created_at']),
            # Partial index
            models.Index(fields=['due_date'], condition=Q(status='todo')),
        ]
```

#### Slide 21.4: Performance Monitoring Tools
- **Django Debug Toolbar:** SQL queries, cache, performance
- **django-silk:** Profiling and query analysis
- **Query Count Middleware:** Log queries per request
- **Custom Profiling Decorators:** Time functions and methods

---

### Part 22: Redis Caching

#### Slide 22.1: Caching Architecture

```
Request ──▶ Cache Check ──▶ Hit ──▶ Return Cached Response
                │
                │ Miss
                ▼
            Database ──▶ Store in Cache ──▶ Return Response
```

#### Slide 22.2: Django Redis Configuration
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

#### Slide 22.3: Caching Strategies

| Type | TTL | Example |
|------|-----|---------|
| **View caching** | 5 minutes | API responses |
| **Query caching** | 1 hour | Expensive queries |
| **Low-level caching** | 24 hours | User profiles |
| **Session caching** | 1 hour | User sessions |

#### Slide 22.4: View Caching
```python
from django.views.decorators.cache import cache_page
from apps.api.cache import cache_response

@cache_page(60 * 5)  # Cache for 5 minutes
def task_stats(request):
    return Response(stats)
```

#### Slide 22.5: Low-Level Caching
```python
from django.core.cache import cache

def get_user_profile(user_id):
    cache_key = f'user_profile:{user_id}'
    profile = cache.get(cache_key)
    if profile is None:
        profile = UserProfile.objects.get(user_id=user_id)
        cache.set(cache_key, profile, 3600)  # Cache for 1 hour
    return profile

def invalidate_user_profile(user_id):
    cache_key = f'user_profile:{user_id}'
    cache.delete(cache_key)
```

---

### Part 23: API Performance

#### Slide 23.1: Performance Bottlenecks

| Bottleneck | Cause | Solution |
|------------|-------|----------|
| **Heavy Serializers** | Too many fields, nested relations | List vs detail serializers |
| **Large Responses** | Sending unnecessary data | `only()`, fields parameter |
| **Slow Queries** | Missing indexes, N+1 queries | Add indexes, select_related |
| **Large Payloads** | No compression | Enable gzip compression |
| **Database Load** | Too many queries | Caching, query optimization |

#### Slide 23.2: Serializer Optimization
```python
# Lightweight serializer for list views
class TaskListSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = ['id', 'title', 'status', 'priority', 'created_at']

# Full serializer for detail views
class TaskDetailSerializer(serializers.ModelSerializer):
    project = ProjectSerializer(read_only=True)
    comments = CommentSerializer(many=True, read_only=True)
    
    class Meta:
        model = Task
        fields = '__all__'
```

#### Slide 23.3: Response Compression

```python
# Django settings
MIDDLEWARE = [
    'django.middleware.gzip.GZipMiddleware',
    # ...
]

# Nginx compression
gzip on;
gzip_vary on;
gzip_proxied any;
gzip_comp_level 6;
gzip_types text/plain text/css text/xml text/javascript 
           application/json application/javascript application/xml+rss;
```

#### Slide 23.4: Connection Pooling
```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'taskflow_db',
        'CONN_MAX_AGE': 600,  # Keep connections alive
        'CONN_HEALTH_CHECKS': True,
        'OPTIONS': {
            'keepalives': 1,
            'keepalives_idle': 30,
            'keepalives_interval': 10,
            'keepalives_count': 5,
        },
    }
}
```

---

### Part 24: Automated Backend Testing

#### Slide 24.1: Testing Pyramid

```
                  ┌──────────┐
                  │  E2E     │  Few
                  │  Tests   │  Slow, comprehensive
               ┌──┴──────────┴──┐
               │  Integration   │  Some
               │  Tests         │  Medium speed
            ┌──┴────────────────┴──┐
            │     Unit Tests       │  Many
            │                      │  Fast, focused
            └──────────────────────┘
```

#### Slide 24.2: Test Types

| Type | Purpose | Tools |
|------|---------|-------|
| **Unit Tests** | Test individual components | pytest |
| **Integration Tests** | Test component interactions | pytest, DRF APIClient |
| **API Tests** | Test endpoints | DRF APIClient |
| **E2E Tests** | Test full user flows | Playwright |

#### Slide 24.3: pytest Configuration
```ini
# pytest.ini
[pytest]
DJANGO_SETTINGS_MODULE = config.settings
python_files = test_*.py *_test.py
testpaths = tests
addopts = 
    --verbose
    --cov=apps
    --cov-report=html
    --cov-report=term
    --cov-fail-under=70
```

#### Slide 24.4: Test Fixtures Example
```python
# conftest.py
@pytest.fixture
def user():
    return User.objects.create_user(
        email='test@example.com',
        username='testuser',
        password='testpass123'
    )

@pytest.fixture
def auth_client(user):
    client = APIClient()
    client.force_authenticate(user=user)
    return client
```

#### Slide 24.5: API Test Example
```python
def test_list_tasks_authenticated(auth_client, task):
    response = auth_client.get(reverse('task-list'))
    assert response.status_code == 200
    assert len(response.data['results']) >= 1

def test_create_task(auth_client, user, project):
    data = {
        'title': 'New Test Task',
        'project': project.id,
        'status': 'todo',
    }
    response = auth_client.post(reverse('task-list'), data)
    assert response.status_code == 201
    assert response.data['title'] == 'New Test Task'
```

---

### Part 25: Frontend Testing

#### Slide 25.1: Frontend Testing Tools

| Tool | Purpose | Use Case |
|------|---------|----------|
| **Jest** | Test runner | Running all tests |
| **React Testing Library** | Component testing | Testing React components |
| **User Event** | User simulation | Simulating user interactions |
| **MSW** | API mocking | Mocking API responses |
| **Playwright** | E2E testing | Testing full user flows |

#### Slide 25.2: Component Test Example
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

#### Slide 25.3: E2E Test Example
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

### Part 26: API Documentation

#### Slide 26.1: OpenAPI with drf-spectacular

```python
# settings.py
SPECTACULAR_SETTINGS = {
    'TITLE': 'TaskFlow API',
    'DESCRIPTION': 'A modern task management platform API',
    'VERSION': '1.0.0',
    'SERVE_INCLUDE_SCHEMA': False,
    'COMPONENT_SPLIT_REQUEST': True,
}

# urls.py
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

#### Slide 26.2: Schema Annotations
```python
from drf_spectacular.utils import extend_schema, OpenApiParameter

@extend_schema(
    summary="List tasks",
    description="Get a list of tasks with optional filtering",
    parameters=[
        OpenApiParameter(name='status', description='Filter by status', type=str),
        OpenApiParameter(name='search', description='Search in title', type=str),
        OpenApiParameter(name='page', description='Page number', type=int),
    ],
    responses={200: TaskSerializer(many=True)},
)
def list(self, request):
    # ...
```

#### Slide 26.3: Documentation Access
- **Swagger UI:** `/api/docs/` - Interactive API exploration
- **ReDoc:** `/api/redoc/` - Clean, readable documentation
- **Schema:** `/api/schema/` - OpenAPI JSON specification

---

### Part 27: Dockerizing Django

#### Slide 27.1: Multi-Stage Dockerfile

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
CMD ["gunicorn", "--config", "gunicorn.conf.py", "config.wsgi:application"]
```

#### Slide 27.2: Dockerfile Layers

```
┌───────────────────────────────────────────────────────┐
│  Layer 5: Application Code (changes frequently)      │
└───────────────────────────────────────────────────────┘
┌───────────────────────────────────────────────────────┐
│  Layer 4: Python Dependencies (changes occasionally)  │
└───────────────────────────────────────────────────────┘
┌───────────────────────────────────────────────────────┐
│  Layer 3: System Packages (rarely changes)            │
└───────────────────────────────────────────────────────┘
┌───────────────────────────────────────────────────────┐
│  Layer 2: Base Python Image                          │
└───────────────────────────────────────────────────────┘
┌───────────────────────────────────────────────────────┐
│  Layer 1: Base OS (Alpine Linux)                    │
└───────────────────────────────────────────────────────┘
```

#### Slide 27.3: Gunicorn Configuration
```python
# gunicorn.conf.py
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = 'sync'
timeout = 30
max_requests = 1000
preload_app = True
```

---

### Part 28: Dockerizing Next.js

#### Slide 28.1: Standalone Output

```javascript
// next.config.js
module.exports = {
    output: 'standalone',  // Self-contained deployment
    compress: true,
    poweredByHeader: false,
};
```

#### Slide 28.2: Next.js Dockerfile
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

#### Slide 28.3: Image Size Comparison
- **Development:** ~1.2GB (with node_modules, source code)
- **Production (standalone):** ~200MB (only necessary files)

---

### Part 29: Docker Compose

#### Slide 29.1: Service Architecture

```
                    ┌─────────────┐
                    │    Nginx    │
                    └──────┬──────┘
                           │
              ┌────────────┴────────────┐
              ▼                         ▼
       ┌─────────────┐           ┌─────────────┐
       │   Next.js   │           │   Django    │
       │   React 19  │           │   Gunicorn  │
       └─────────────┘           └──────┬──────┘
                                        │
                           ┌────────────┴────────────┐
                           ▼                         ▼
                    ┌─────────────┐           ┌─────────────┐
                    │ PostgreSQL  │           │    Redis    │
                    └─────────────┘           └─────────────┘
```

#### Slide 29.2: docker-compose.yml
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
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

  nginx:
    image: nginx:alpine
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    ports:
      - "80:80"
    depends_on:
      - backend
      - frontend

volumes:
  postgres_data:
  redis_data:
```

---

### Part 30: Production Configuration

#### Slide 30.1: Environment-Specific Settings

```
backend/config/settings/
├── __init__.py
├── base.py              # Shared settings
├── development.py       # Development overrides
└── production.py        # Production settings
```

#### Slide 30.2: Production Security Settings
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
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True

CORS_ALLOWED_ORIGINS = env.list('CORS_ALLOWED_ORIGINS')
CORS_ALLOW_CREDENTIALS = True
```

#### Slide 30.3: Production Logging
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
        'security': {
            'level': 'INFO',
            'filename': '/app/logs/security.log',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['file'],
            'level': 'INFO',
        },
        'django.security': {
            'handlers': ['security'],
            'level': 'INFO',
        },
    },
}
```

---

### Part 31: Reverse Proxy & Networking

#### Slide 31.1: Nginx Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Internet                              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    Nginx (Port 80/443)                     │
│  - SSL/TLS Termination                                     │
│  - Load Balancing                                          │
│  - Rate Limiting                                           │
│  - Static File Serving                                     │
│  - Request Routing                                         │
└────────────────────────┬────────────────────────────────────┘
                         │
            ┌────────────┴────────────┐
            ▼                         ▼
┌─────────────────┐        ┌─────────────────┐
│   /api/*        │        │   /*            │
│   (Backend)     │        │   (Frontend)    │
│   Port 8000     │        │   Port 3000     │
└─────────────────┘        └─────────────────┘
```

#### Slide 31.2: SSL/TLS Configuration
```nginx
server {
    listen 443 ssl http2;
    server_name api.taskflow.com;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
}
```

#### Slide 31.3: Rate Limiting
```nginx
# Rate limiting zones
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=auth_limit:10m rate=2r/s;

location /api/ {
    limit_req zone=api_limit burst=20 nodelay;
    proxy_pass http://backend;
}

location /api/v1/token/ {
    limit_req zone=auth_limit burst=5 nodelay;
    proxy_pass http://backend;
}
```

---

### Part 32: CI/CD

#### Slide 32.1: CI/CD Pipeline

```
Push Code
     ↓
Lint Check
     ↓
Unit Tests
     ↓
E2E Tests
     ↓
Security Scan
     ↓
Build Docker Image
     ↓
Push to Registry
     ↓
Deploy to Production
     ↓
Health Check
```

#### Slide 32.2: GitHub Actions Workflow
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

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Build Docker image
        run: docker build -t taskflow-backend .

      - name: Push to registry
        run: docker push registry.example.com/taskflow-backend

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to server
        run: |
          ssh user@server "docker-compose pull && docker-compose up -d"
```

#### Slide 32.3: Deployment Stages
1. **Pull Request:** Run tests, lint, build preview
2. **Merge to Main:** Build production image, deploy to staging
3. **Staging:** Full validation, manual approval
4. **Production:** Deploy with health checks, rollback if needed

---

### Part 33: Observability & Production Operations

#### Slide 33.1: Observability Pillars

```
┌─────────────────────────────────────────────────────────────┐
│                     Logs                                    │
│  - Structured JSON logs                                    │
│  - Request/response logging                                │
│  - Error logs                                              │
│  - Audit logs                                              │
├─────────────────────────────────────────────────────────────┤
│                     Metrics                                 │
│  - Request rate                                             │
│  - Error rate                                               │
│  - Response time                                            │
│  - System resources                                         │
├─────────────────────────────────────────────────────────────┤
│                     Traces                                  │
│  - Request flow                                             │
│  - Service dependencies                                     │
│  - Performance bottlenecks                                  │
└─────────────────────────────────────────────────────────────┘
```

#### Slide 33.2: Key Metrics to Monitor

| Metric | Alert Threshold |
|--------|-----------------|
| **Request Rate** | Traffic spikes/drops |
| **Error Rate** | > 5% over 5 minutes |
| **Response Time (P95)** | > 500ms |
| **CPU Usage** | > 80% sustained |
| **Memory Usage** | > 85% |
| **Database Connections** | > 80% of pool |

#### Slide 33.3: Structured Logging
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

#### Slide 33.4: Sentry Integration
```python
import sentry_sdk

sentry_sdk.init(
    dsn=SENTRY_DSN,
    integrations=[DjangoIntegration()],
    traces_sample_rate=0.1,
    environment='production',
    release='1.0.0',
)

sentry_sdk.set_user({
    'id': user.id,
    'email': user.email,
})

sentry_sdk.set_tag('environment', 'production')
```

---

## Appendices Overview

### Appendix A: Deep Dives
- REST Architecture Deep Dive (Richardson Maturity Model, HATEOAS)
- Django ORM Deep Dive (QuerySet evaluation, optimization patterns)
- DRF Deep Dive (Authentication comparison, custom authentication, permission classes)
- Next.js Deep Dive (Server vs Client Components, App Router patterns)
- JWT Deep Dive (Token structure, security best practices)
- Docker Deep Dive (Layer caching, multi-stage builds)
- Testing Deep Dive (Fixture patterns, mocking, coverage)

### Appendix B: Complete API Reference
- All endpoints with request/response examples
- Authentication requirements
- Error codes and messages
- Role-based permission matrix

### Appendix C: Deployment & Infrastructure
- AWS Deployment Guide
- Google Cloud Platform Guide
- Azure Deployment Guide
- SSL/TLS Configuration
- Monitoring Setup

### Appendix D: Development Environment Setup
- System Requirements
- Software Installation
- VS Code Configuration
- Project Setup Script

### Appendix E: Docker Commands & Best Practices
- Container Management
- Image Management
- Docker Compose Commands
- Dockerfile Best Practices
- Security Best Practices

### Appendix F: PostgreSQL Reference
- psql Commands
- Table Operations
- Index Management
- Query Optimization
- Backup and Recovery
- Configuration Tuning

### Appendix G: Redis Reference
- Redis Commands (Strings, Hashes, Lists, Sets, Sorted Sets)
- Pub/Sub Commands
- Lua Scripting
- Django Redis Configuration
- Caching Patterns

### Appendix H: Git Commands & Workflows
- Repository Setup
- Basic Commands
- Branch Commands
- Remote Commands
- Feature Branch Workflow
- Hotfix Workflow
- Release Workflow

### Appendix I: Security Best Practices
- Django Security Checklist
- JWT Security Best Practices
- Next.js Security Best Practices
- Docker Security Best Practices
- Database Security
- Cloud Security Best Practices

### Appendix J: Performance Optimization Guide
- Django ORM Performance
- Database Indexing Strategies
- Redis Caching
- Nginx Performance Tuning
- Frontend Performance Optimization

### Appendix K: Troubleshooting Guide
- Django Errors
- DRF Errors
- Next.js Errors
- Database Errors
- Docker Errors
- Common Issues and Solutions

### Appendix L: Glossary of Terms
- General Concepts
- Backend Terms
- Frontend Terms
- Database Terms
- DevOps Terms
- Security Terms

### Appendix M: Additional Resources
- Official Documentation
- Books
- Online Courses
- Community Forums
- Development Tools
- Deployment Platforms

### Appendix N: Django ORM Cheat Sheet
- CRUD Operations
- Field Lookups
- Relationships
- Aggregations & Annotations
- Query Optimization

### Appendix O: Frontend State Management
- Local State
- URL State
- Form State
- Server State (React Query)
- Context API
- Zustand
- Redux Toolkit

### Appendix P: Deployment Checklist
- Pre-Deployment Checklist
- Backend Deployment Checklist
- Frontend Deployment Checklist
- Infrastructure Checklist
- Monitoring Checklist
- Go-Live Checklist
- Rollback Plan

### Appendix Q: Project Templates
- Minimal DRF API Template
- Full Stack Template (Django + Next.js)
- Microservice Template
- Serverless Template

### Appendix R: Production Monitoring Dashboard
- API Monitoring Dashboard
- Database Monitoring Dashboard
- System Monitoring Dashboard
- Alert Rules Configuration
- Log Aggregation Configuration

### Appendix S: Performance Tuning Reference
- Django Performance Tuning
- PostgreSQL Tuning
- Redis Tuning
- Nginx Tuning
- Next.js Performance Tuning

### Appendix T: Common Error Messages
- Django Errors & Solutions
- DRF Errors & Solutions
- Next.js Errors & Solutions
- Database Errors & Solutions
- Docker Errors & Solutions

### Appendix U: Django & Next.js Integration Patterns
- Data Fetching Strategies
- Authentication Patterns
- Data Synchronization Patterns
- Form Handling Patterns
- File Upload Patterns
- Error Handling Patterns

### Appendix V: Environment Variables Reference
- Django Backend Variables
- Next.js Frontend Variables
- Database Variables
- Docker Variables
- CI/CD Variables

### Appendix W: Complete Technology Stack
- Backend Technologies
- Frontend Technologies
- Database Technologies
- DevOps Technologies
- CI/CD Technologies

### Appendix X: Complete Project Structure
- Project Root
- Backend Structure
- Frontend Structure
- Nginx Structure
- Observability Structure
- Documentation Structure

### Appendix Y: Debugging & Profiling Reference
- Django Debugging Tools
- Python Debugging Tools
- Database Debugging
- Next.js Debugging
- Performance Profiling
- Memory Profiling

### Appendix Z: Complete Index
- Part Index
- Technology Index
- Concept Index
- Code Pattern Index
- Error Index
- Quick Reference Cards

---

## Primers Overview

### Primer 1: Python & Django Fundamentals
- Python Variables and Data Types
- Control Flow
- Functions
- Classes and OOP
- Django Project Structure
- Django Models, Views, Templates
- Django ORM Queries
- Django Forms and Admin

### Primer 2: JavaScript & React Fundamentals
- JavaScript Variables and Data Types
- Functions (Arrow functions, callbacks)
- Objects and Prototypes
- Promises and Async/Await
- React Components (Functional, Hooks)
- Props and State
- Lifecycle and Hooks (useEffect, useMemo, useCallback)
- Forms and Events
- Custom Hooks

### Primer 3: HTTP & REST API Fundamentals
- What is HTTP?
- HTTP Request/Response Structure
- HTTP Methods (GET, POST, PUT, PATCH, DELETE)
- HTTP Status Codes (2xx, 3xx, 4xx, 5xx)
- HTTP Headers (Request, Response)
- What is REST?
- REST Principles (6 Constraints)
- Resource-Oriented URLs
- API Versioning
- Request and Response Formats
- CRUD Operations with REST

### Primer 4: Docker & Containerization
- What is Docker?
- Docker Architecture
- Docker Components (Images, Containers, Volumes, Networks)
- Dockerfile Structure and Instructions
- Image Layers
- Multi-Stage Builds
- Docker Compose
- Container Orchestration Concepts (Kubernetes, ECS)

### Primer 5: Git & Version Control
- What is Git?
- Git Architecture
- Repository Setup
- Basic Commands (add, commit, status, log)
- Branch Commands (branch, checkout, merge, rebase)
- Remote Commands (remote, fetch, pull, push)
- Stash, Reset, Revert
- Git Workflows (Feature Branch, Hotfix, Release)
- Git Hooks

### Primer 6: SQL & Database Fundamentals
- Database Fundamentals (Relational, PostgreSQL)
- Database Relationships (1:1, 1:N, N:N)
- PostgreSQL Commands (psql)
- SQL Fundamentals (CREATE, SELECT, INSERT, UPDATE, DELETE)
- Advanced SQL (Aggregations, Window Functions, JSON Operations)
- Full-Text Search
- Database Indexes
- Query Analysis and Optimization

### Primer 7: Testing Fundamentals
- Why Test?
- Testing Pyramid
- Test Types (Unit, Integration, API, E2E, Component)
- Backend Testing with pytest (Fixtures, Model Tests, Serializer Tests, API Tests)
- Frontend Testing with Jest (Component Tests, Form Tests)
- E2E Tests with Playwright
- Mocking (MSW, React Hooks)

### Primer 8: Authentication & Authorization
- Authentication vs Authorization
- Authentication Factors
- Authentication Methods (Basic Auth, Session Auth, Token Auth, JWT, OAuth2)
- JWT Structure and Lifecycle
- OAuth 2.0 Flow
- Authorization Models (ACL, RBAC, ABAC)
- Security Attacks (Brute Force, Credential Stuffing, Privilege Escalation, IDOR)
- Security Best Practices

### Primer 9: Docker & Container Orchestration
- Docker Fundamentals (Review)
- Docker Compose (Review)
- Container Orchestration (What, Why, Tools)
- Kubernetes Architecture
- Kubernetes Resources (Pod, Deployment, Service, Ingress, ConfigMap, Secret)
- Docker Best Practices

### Primer 10: Development Tools & Workflow
- Code Editors & IDEs (VS Code, PyCharm, WebStorm)
- Terminal & Shell Setup
- Version Control Workflows
- Package Managers (pip, npm)
- Development Workflows (Full Stack, Database, Testing)
- Debugging Workflow (Backend, Frontend)
- Performance Monitoring (Backend, Frontend)
- Troubleshooting Common Issues

---

## Final Slide: Course Conclusion

### What You've Built

```
                    ┌──────────────────────┐
                    │       Browser        │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │     Next.js 16       │
                    │      React 19        │
                    │    App Router        │
                    └──────────┬───────────┘
                               │
                         HTTP / JSON
                               │
                               ▼
                    ┌──────────────────────┐
                    │ Django REST          │
                    │ Framework            │
                    │      API             │
                    └──────────┬───────────┘
                               │
                     ┌─────────┴─────────┐
                     ▼                   ▼
              ┌─────────────┐     ┌─────────────┐
              │ PostgreSQL  │     │    Redis    │
              └─────────────┘     └─────────────┘
```

### Skills Gained

**Backend:**
- ✅ Build production-quality APIs with DRF
- ✅ Design RESTful resources and URL structures
- ✅ Implement authentication and authorization
- ✅ Optimize Django ORM queries
- ✅ Implement Redis caching
- ✅ Test APIs automatically
- ✅ Generate OpenAPI documentation

**Frontend:**
- ✅ Build applications with Next.js 16 and React 19
- ✅ Understand Server Components and Client Components
- ✅ Build App Router applications
- ✅ Consume external DRF APIs
- ✅ Implement authenticated frontend flows
- ✅ Implement pagination, search, and filtering

**Production:**
- ✅ Containerize Django and Next.js with Docker
- ✅ Configure Nginx as reverse proxy
- ✅ Build CI/CD pipelines
- ✅ Implement monitoring and logging

### Key Principles

> Django owns the data and business rules.
> DRF exposes the application through a secure API.
> Next.js delivers the modern frontend experience.
> React powers interactive interfaces.
> PostgreSQL stores the data.
> Redis accelerates frequently accessed information.
> Docker makes the environment reproducible.
> Automated tests and CI/CD make the system maintainable.

---

*This concludes the Django REST Framework & Next.js 16: From Scratch to Production masterclass slide deck.*
