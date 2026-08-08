# Django REST Framework & Next.js 16: Student Workbook

## From Scratch to Production — Complete Learning Companion

---

## Workbook Introduction

### How to Use This Workbook

This workbook is designed to accompany the **Django REST Framework & Next.js 16: From Scratch to Production** masterclass. It contains:

1. **Exercises** - Hands-on coding activities for each part
2. **Code Labs** - Complete working examples to implement
3. **Review Questions** - Check your understanding
4. **Challenge Problems** - Extend your learning
5. **Code Templates** - Ready-to-use code snippets
6. **Checklists** - Track your progress
7. **Answer Keys** - Verify your solutions

### Workbook Structure

Each part of the masterclass has a corresponding section in this workbook:

- **Learning Objectives** - What you'll achieve
- **Key Concepts** - Summary of important ideas
- **Hands-On Exercise** - Step-by-step coding activity
- **Code Lab** - Complete implementation example
- **Review Questions** - Test your knowledge
- **Challenge** - Extend the application
- **Checkpoint** - Verify your progress

---

## Part 0: Introduction

### Learning Objectives
- Understand the course architecture
- Set up your development environment
- Install required software

### Key Concepts
- Decoupled architecture (Frontend ↔ API ↔ Backend)
- Django owns data and business rules
- Next.js owns the frontend experience
- PostgreSQL stores data, Redis accelerates it

### Hands-On Exercise: Environment Setup

**Task 1: Verify Your System**

```bash
# Check Python version
python --version
# Should show 3.12 or higher

# Check Node.js version
node --version
# Should show 20.0 or higher

# Check PostgreSQL
postgres --version
# Should show 15 or higher

# Check Redis
redis-server --version
# Should show 7 or higher

# Check Docker
docker --version
# Should show 24 or higher

# Check Docker Compose
docker-compose --version
# Should show 2.20 or higher
```

**Task 2: Create Project Directory**

```bash
mkdir django-nextjs-masterclass
cd django-nextjs-masterclass
```

**Task 3: Install VS Code Extensions**

```bash
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension bradlc.vscode-tailwindcss
code --install-extension esbenp.prettier-vscode
code --install-extension dbaeumer.vscode-eslint
code --install-extension ms-azuretools.vscode-docker
```

### Review Questions

1. What are the three main layers of the application architecture?
2. What is the benefit of a decoupled architecture?
3. What is the role of the API in a decoupled application?

### Challenge

Create a diagram showing the complete architecture with all components (Browser, Next.js, DRF API, PostgreSQL, Redis).

---

## Part 1: REST Architecture & HTTP Fundamentals

### Learning Objectives
- Understand REST principles
- Know HTTP methods and status codes
- Design resource-oriented URLs
- Work with JSON

### Key Concepts

**REST Constraints:**
1. Client-Server Separation
2. Statelessness
3. Cacheability
4. Uniform Interface
5. Layered System
6. Code on Demand (optional)

**HTTP Methods:**
| Method | Purpose | Idempotent? |
|--------|---------|-------------|
| GET | Retrieve | Yes |
| POST | Create | No |
| PUT | Replace | Yes |
| PATCH | Update | No |
| DELETE | Delete | Yes |

### Hands-On Exercise: HTTP Requests

**Task 1: Test HTTP Methods with curl**

```bash
# GET request
curl -X GET https://jsonplaceholder.typicode.com/todos/1

# POST request
curl -X POST https://jsonplaceholder.typicode.com/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "New todo", "completed": false}'

# PUT request
curl -X PUT https://jsonplaceholder.typicode.com/todos/1 \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated", "completed": true}'

# DELETE request
curl -X DELETE https://jsonplaceholder.typicode.com/todos/1
```

**Task 2: Design Resource URLs**

Design RESTful URLs for the following resources:
1. List all projects
2. Get a specific project by ID
3. Create a new project
4. Update a project
5. Delete a project
6. List all tasks for a project
7. Get a specific task
8. Create a task in a project

### Code Lab: HTTP Request/Response Cycle

```python
# Example of an HTTP request handler (conceptual)
class TaskHandler:
    def handle_get(self, request):
        # GET /api/tasks/1
        task = get_task(1)
        return {
            'status': 200,
            'body': {
                'id': 1,
                'title': 'Complete API documentation',
                'status': 'in_progress'
            }
        }
    
    def handle_post(self, request):
        # POST /api/tasks/
        data = request.body
        task = create_task(data)
        return {
            'status': 201,
            'body': task
        }
```

### Review Questions

1. What HTTP method would you use to fetch a list of tasks?
2. What status code should be returned when a resource is created?
3. What is the difference between PUT and PATCH?
4. Why should URLs use nouns instead of verbs?

### Challenge

Design a complete REST API for a blog with posts, comments, and authors. Include all endpoints, HTTP methods, and expected status codes.

---

## Part 2: Django 6 Backend Foundations

### Learning Objectives
- Set up a Django project
- Configure PostgreSQL
- Create Django models
- Run migrations
- Create a superuser

### Key Concepts

**Project Structure:**
```
backend/
├── config/
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── apps/
├── manage.py
└── requirements/
```

**Models:**
- `models.Model` base class
- Field types: `CharField`, `TextField`, `ForeignKey`, etc.
- Relationships: `ForeignKey`, `OneToOneField`, `ManyToManyField`

### Hands-On Exercise: Django Setup

**Task 1: Create Virtual Environment**

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

**Task 2: Install Dependencies**

```bash
pip install Django psycopg2-binary django-environ python-dotenv
```

**Task 3: Create requirements/base.txt**

```txt
Django>=6.0,<6.1
psycopg2-binary>=2.9.0
django-environ>=0.11.0
python-dotenv>=1.0.0
```

**Task 4: Create Django Project**

```bash
django-admin startproject config .
```

**Task 5: Create .env file**

```bash
# .env
SECRET_KEY=django-insecure-dev-key
DEBUG=True
DATABASE_URL=postgresql://taskflow_user:taskflow_pass@localhost:5432/taskflow_db
```

### Code Lab: User Model

**backend/apps/users/models.py**

```python
from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    class Roles(models.TextChoices):
        ADMIN = 'admin', 'Administrator'
        MANAGER = 'manager', 'Manager'
        MEMBER = 'member', 'Member'
        VIEWER = 'viewer', 'Viewer'
    
    email = models.EmailField(unique=True)
    bio = models.TextField(blank=True, null=True)
    role = models.CharField(max_length=20, choices=Roles.choices, default=Roles.MEMBER)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']
    
    def __str__(self):
        return self.email
```

### Review Questions

1. What is the purpose of a virtual environment?
2. What is the difference between a Django project and a Django app?
3. What is the purpose of migrations?
4. Why do we create a custom User model instead of using Django's built-in User?

### Challenge

Create a `Tag` model with fields: `name` (max length 50) and `created_at`. Add a ManyToMany relationship from `Task` to `Tag`. Create the migration and apply it.

---

## Part 3: DRF Serializers

### Learning Objectives
- Understand serializers
- Create ModelSerializers
- Implement validation
- Handle nested relationships

### Key Concepts

**Serializer Types:**
- `Serializer` - Manual field definitions
- `ModelSerializer` - Auto-generated from model
- `HyperlinkedModelSerializer` - Hyperlinks for relationships

**Validation Layers:**
1. Field-level: `validate_<field_name>()`
2. Object-level: `validate()`
3. Model-level: Model validation

### Hands-On Exercise: Create Serializers

**Task 1: Create Task Serializer**

```python
# backend/apps/tasks/serializers.py
from rest_framework import serializers
from .models import Task

class TaskSerializer(serializers.ModelSerializer):
    project_name = serializers.CharField(source='project.name', read_only=True)
    
    class Meta:
        model = Task
        fields = ['id', 'title', 'description', 'status', 'priority', 
                  'due_date', 'project', 'project_name', 'assigned_to',
                  'created_by', 'created_at', 'updated_at']
        read_only_fields = ['created_by', 'created_at', 'updated_at']
```

**Task 2: Add Validation**

```python
class TaskCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = ['title', 'description', 'status', 'priority', 'due_date', 
                  'project', 'assigned_to']
    
    def validate_title(self, value):
        if len(value.strip()) < 3:
            raise serializers.ValidationError("Title must be at least 3 characters")
        return value.strip()
    
    def validate(self, data):
        if data.get('due_date') and data['due_date'] < timezone.now():
            raise serializers.ValidationError("Due date must be in the future")
        return data
```

### Code Lab: Complete Serializer Example

**backend/apps/tasks/serializers.py**

```python
from rest_framework import serializers
from django.utils import timezone
from .models import Task
from apps.projects.models import Project

class TaskListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for list views."""
    project_name = serializers.CharField(source='project.name')
    assigned_to_username = serializers.CharField(source='assigned_to.username')
    
    class Meta:
        model = Task
        fields = ['id', 'title', 'status', 'priority', 'project_name', 
                  'assigned_to_username', 'due_date', 'created_at']

class TaskDetailSerializer(serializers.ModelSerializer):
    """Full serializer for detail views."""
    project_name = serializers.CharField(source='project.name')
    assigned_to_username = serializers.CharField(source='assigned_to.username')
    created_by_username = serializers.CharField(source='created_by.username')
    status_display = serializers.CharField(source='get_status_display')
    priority_display = serializers.CharField(source='get_priority_display')
    comment_count = serializers.IntegerField(read_only=True)
    
    class Meta:
        model = Task
        fields = '__all__'
```

### Review Questions

1. What is the difference between `Serializer` and `ModelSerializer`?
2. How do you add field-level validation to a serializer?
3. What is the purpose of `read_only_fields`?
4. Why would you use different serializers for list and detail views?

### Challenge

Create a `ProjectDetailSerializer` that includes a nested list of all tasks in the project, including their comments count.

---

## Part 4: Building API Views

### Learning Objectives
- Create API views with @api_view
- Implement CRUD endpoints
- Handle HTTP methods
- Return proper status codes

### Key Concepts

**View Types:**
| Type | Use Case |
|------|----------|
| `@api_view` | Simple endpoints, one-off actions |
| `APIView` | Custom logic, non-standard operations |
| `GenericAPIView` | Generic, with customization |
| `ListCreateAPIView` | List + Create |
| `RetrieveUpdateDestroyAPIView` | Full CRUD |

### Hands-On Exercise: Create API Views

**Task 1: Create Task Views**

```python
# backend/apps/tasks/views.py
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Task
from .serializers import TaskSerializer, TaskCreateSerializer

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
            response_serializer = TaskSerializer(task)
            return Response(response_serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
def task_detail(request, pk):
    try:
        task = Task.objects.get(pk=pk)
    except Task.DoesNotExist:
        return Response({'detail': 'Task not found'}, status=status.HTTP_404_NOT_FOUND)
    
    if request.method == 'GET':
        serializer = TaskSerializer(task)
        return Response(serializer.data)
    
    elif request.method in ['PUT', 'PATCH']:
        serializer = TaskSerializer(task, data=request.data, partial=(request.method == 'PATCH'))
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    elif request.method == 'DELETE':
        task.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
```

### Code Lab: URL Configuration

**backend/apps/tasks/urls.py**

```python
from django.urls import path
from . import views

urlpatterns = [
    path('', views.task_list, name='task-list'),
    path('<int:pk>/', views.task_detail, name='task-detail'),
]
```

### Review Questions

1. What is the difference between `@api_view` and `APIView`?
2. What status codes should be returned for successful operations?
3. What is the difference between PUT and PATCH in terms of request handling?
4. Why is it important to handle exceptions like `Task.DoesNotExist`?

### Challenge

Add a `task_status_update` view that only updates the status field. Use PATCH method and return 200 OK with the updated task.

---

## Part 5: Next.js 16 Foundations

### Learning Objectives
- Set up Next.js with App Router
- Understand Server vs Client Components
- Create pages and layouts
- Configure Tailwind CSS

### Key Concepts

**Server vs Client Components:**

| Feature | Server | Client |
|---------|--------|--------|
| Async/Await | ✅ | ❌ |
| React Hooks | ❌ | ✅ |
| Browser APIs | ❌ | ✅ |
| Event Handlers | ❌ | ✅ |
| SEO | ✅ Excellent | ❌ Limited |

### Hands-On Exercise: Next.js Setup

**Task 1: Create Next.js Project**

```bash
cd frontend
npx create-next-app@latest . --typescript --tailwind --eslint --app --use-npm
```

**Task 2: Create Directory Structure**

```bash
mkdir -p app/(auth)/login
mkdir -p app/(auth)/register
mkdir -p app/(dashboard)/dashboard
mkdir -p app/(dashboard)/projects
mkdir -p app/(dashboard)/tasks
mkdir -p components/ui
mkdir -p lib/api
mkdir -p types
```

**Task 3: Create Root Layout**

```tsx
// app/layout.tsx
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
    title: 'TaskFlow - Task Management',
    description: 'A modern task management platform',
};

export default function RootLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    return (
        <html lang="en">
            <body className={inter.className}>{children}</body>
        </html>
    );
}
```

**Task 4: Create Landing Page**

```tsx
// app/page.tsx
export default function LandingPage() {
    return (
        <div className="min-h-screen bg-gradient-to-b from-primary-50 to-white">
            <div className="container mx-auto px-4 py-20">
                <h1 className="text-4xl font-bold text-center">
                    Welcome to TaskFlow
                </h1>
                <p className="text-center text-gray-600 mt-4">
                    A modern task management platform
                </p>
            </div>
        </div>
    );
}
```

### Code Lab: Dashboard Layout

**app/(dashboard)/layout.tsx**

```tsx
'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

export default function DashboardLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    const pathname = usePathname();
    
    return (
        <div className="flex min-h-screen">
            <aside className="w-64 bg-gray-900 text-white p-4">
                <h2 className="text-xl font-bold mb-8">TaskFlow</h2>
                <nav className="space-y-2">
                    <Link href="/dashboard" className="block py-2 px-4 rounded hover:bg-gray-800">
                        Dashboard
                    </Link>
                    <Link href="/projects" className="block py-2 px-4 rounded hover:bg-gray-800">
                        Projects
                    </Link>
                    <Link href="/tasks" className="block py-2 px-4 rounded hover:bg-gray-800">
                        Tasks
                    </Link>
                </nav>
            </aside>
            <main className="flex-1 p-6 bg-gray-50">
                {children}
            </main>
        </div>
    );
}
```

### Review Questions

1. What is the difference between Server and Client Components?
2. When would you use a Server Component vs a Client Component?
3. What is the purpose of the App Router?
4. How do you create a dynamic route in Next.js?

### Challenge

Create a `ProjectCard` component that displays project information. Use it in the projects page with sample data.

---

## Part 6: Connecting Next.js to DRF

### Learning Objectives
- Create an API client
- Fetch data in Server Components
- Handle errors and loading states
- Submit data from forms

### Key Concepts

**Data Fetching Patterns:**
| Pattern | Where | When |
|---------|-------|------|
| Server Fetching | Server Component | Initial page load |
| Client Fetching | Client Component | User interactions |
| Mutations | Client Component | Form submissions |

### Hands-On Exercise: API Client

**Task 1: Create API Client**

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

export async function post<T>(endpoint: string, data: any): Promise<T> {
    const response = await fetch(`${API_URL}${endpoint}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
    });
    
    if (!response.ok) {
        const error = await response.json();
        throw new Error(error.detail || `API Error: ${response.status}`);
    }
    
    return response.json();
}
```

**Task 2: Create Endpoints**

```typescript
// lib/api/endpoints.ts
export const ENDPOINTS = {
    tasks: {
        list: '/tasks/',
        detail: (id: number) => `/tasks/${id}/`,
    },
    projects: {
        list: '/projects/',
        detail: (id: number) => `/projects/${id}/`,
    },
};
```

### Code Lab: Server Component Data Fetching

**app/(dashboard)/tasks/page.tsx**

```tsx
import { get } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { Task } from '@/types';

export default async function TasksPage() {
    const tasks = await get<Task[]>(ENDPOINTS.tasks.list);
    
    return (
        <div>
            <h1 className="text-2xl font-bold mb-6">Tasks</h1>
            <div className="space-y-4">
                {tasks.map((task) => (
                    <div key={task.id} className="bg-white p-4 rounded-lg shadow">
                        <h3 className="font-semibold">{task.title}</h3>
                        <p className="text-gray-600">{task.description}</p>
                        <span className="inline-block px-2 py-1 text-sm bg-blue-100 text-blue-800 rounded">
                            {task.status}
                        </span>
                    </div>
                ))}
            </div>
        </div>
    );
}
```

### Review Questions

1. Why is it better to fetch data in Server Components when possible?
2. What is the purpose of the API client abstraction?
3. How do you handle errors when fetching data?
4. What is the difference between server-side and client-side fetching?

### Challenge

Create a `TaskForm` component that submits a new task to the API. Handle loading states and validation errors.

---

## Part 7: CRUD Operations Across the Stack

### Learning Objectives
- Implement complete CRUD operations
- Handle form validation
- Display toast notifications
- Implement delete with confirmation

### Key Concepts

**CRUD Endpoints:**
| Operation | HTTP Method | URL |
|-----------|-------------|-----|
| Create | POST | /api/tasks/ |
| Read (List) | GET | /api/tasks/ |
| Read (Detail) | GET | /api/tasks/{id}/ |
| Update | PUT/PATCH | /api/tasks/{id}/ |
| Delete | DELETE | /api/tasks/{id}/ |

### Hands-On Exercise: Complete CRUD

**Task 1: Create Toast Notification System**

```tsx
// lib/context/ToastContext.tsx
import { createContext, useContext, useState } from 'react';

type ToastType = 'success' | 'error' | 'info' | 'warning';

interface Toast {
    id: string;
    message: string;
    type: ToastType;
}

export function ToastProvider({ children }: { children: React.ReactNode }) {
    const [toasts, setToasts] = useState<Toast[]>([]);
    
    const addToast = (message: string, type: ToastType = 'info') => {
        const id = Math.random().toString(36).substring(2);
        setToasts((prev) => [...prev, { id, message, type }]);
        setTimeout(() => {
            setToasts((prev) => prev.filter((t) => t.id !== id));
        }, 3000);
    };
    
    return (
        <ToastContext.Provider value={{ addToast }}>
            {children}
            <div className="fixed bottom-4 right-4 space-y-2">
                {toasts.map((toast) => (
                    <div key={toast.id} className={`p-4 rounded-lg shadow-lg ${getToastColor(toast.type)}`}>
                        {toast.message}
                    </div>
                ))}
            </div>
        </ToastContext.Provider>
    );
}

function getToastColor(type: ToastType): string {
    switch (type) {
        case 'success': return 'bg-green-500 text-white';
        case 'error': return 'bg-red-500 text-white';
        case 'warning': return 'bg-yellow-500 text-white';
        default: return 'bg-blue-500 text-white';
    }
}
```

**Task 2: Create Project Form**

```tsx
// app/(dashboard)/projects/components/ProjectForm.tsx
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { post } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { useToast } from '@/lib/context/ToastContext';

export function ProjectForm() {
    const router = useRouter();
    const { addToast } = useToast();
    const [loading, setLoading] = useState(false);
    const [name, setName] = useState('');
    const [description, setDescription] = useState('');
    const [errors, setErrors] = useState<Record<string, string[]>>({});
    
    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setErrors({});
        
        try {
            await post(ENDPOINTS.projects.list, { name, description });
            addToast('Project created successfully!', 'success');
            router.push('/projects');
        } catch (error: any) {
            if (error.message) {
                setErrors({ general: [error.message] });
            }
            addToast('Failed to create project', 'error');
        } finally {
            setLoading(false);
        }
    };
    
    return (
        <form onSubmit={handleSubmit} className="space-y-4">
            <div>
                <label htmlFor="name" className="block text-sm font-medium text-gray-700">
                    Name *
                </label>
                <input
                    id="name"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm"
                    required
                />
            </div>
            
            <div>
                <label htmlFor="description" className="block text-sm font-medium text-gray-700">
                    Description
                </label>
                <textarea
                    id="description"
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm"
                    rows={4}
                />
            </div>
            
            <button
                type="submit"
                disabled={loading}
                className="bg-blue-600 text-white px-4 py-2 rounded-md disabled:opacity-50"
            >
                {loading ? 'Creating...' : 'Create Project'}
            </button>
        </form>
    );
}
```

### Code Lab: Delete Confirmation Modal

**components/ui/Modal.tsx**

```tsx
'use client';

interface ModalProps {
    isOpen: boolean;
    onClose: () => void;
    onConfirm: () => void;
    title: string;
    description: string;
    confirmText?: string;
}

export function Modal({
    isOpen,
    onClose,
    onConfirm,
    title,
    description,
    confirmText = 'Confirm',
}: ModalProps) {
    if (!isOpen) return null;
    
    return (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg p-6 max-w-md w-full">
                <h2 className="text-xl font-bold mb-2">{title}</h2>
                <p className="text-gray-600 mb-6">{description}</p>
                <div className="flex justify-end gap-3">
                    <button
                        onClick={onClose}
                        className="px-4 py-2 border rounded-md hover:bg-gray-50"
                    >
                        Cancel
                    </button>
                    <button
                        onClick={onConfirm}
                        className="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700"
                    >
                        {confirmText}
                    </button>
                </div>
            </div>
        </div>
    );
}
```

### Review Questions

1. What is the complete CRUD endpoint map for tasks?
2. How do you handle validation errors from the API?
3. What is the purpose of optimistic updates?
4. How do you prevent accidental deletions?

### Challenge

Implement optimistic updates for task status changes. When a user clicks a status button, update the UI immediately and send the request in the background.

---

## Part 8: Generic Views, ViewSets & Routers

### Learning Objectives
- Replace function-based views with ViewSets
- Use DefaultRouter for consistent URLs
- Add custom actions with @action

### Key Concepts

**ViewSet Actions:**
| HTTP Method | URL | Action |
|-------------|-----|--------|
| GET | /tasks/ | list() |
| POST | /tasks/ | create() |
| GET | /tasks/{id}/ | retrieve() |
| PUT | /tasks/{id}/ | update() |
| PATCH | /tasks/{id}/ | partial_update() |
| DELETE | /tasks/{id}/ | destroy() |

### Hands-On Exercise: Convert to ViewSet

**Task 1: Create Task ViewSet**

```python
# backend/apps/tasks/views.py
from rest_framework import viewsets
from .models import Task
from .serializers import TaskSerializer, TaskCreateSerializer

class TaskViewSet(viewsets.ModelViewSet):
    queryset = Task.objects.all()
    permission_classes = [IsAuthenticated]
    
    def get_serializer_class(self):
        if self.action == 'create':
            return TaskCreateSerializer
        return TaskSerializer
    
    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)
```

**Task 2: Add Custom Action**

```python
from rest_framework.decorators import action
from rest_framework.response import Response

class TaskViewSet(viewsets.ModelViewSet):
    # ... existing code ...
    
    @action(detail=True, methods=['post'])
    def complete(self, request, pk=None):
        task = self.get_object()
        task.status = 'done'
        task.save()
        return Response({'status': 'completed'})
    
    @action(detail=False, methods=['get'])
    def stats(self, request):
        queryset = self.get_queryset()
        stats = {
            'total': queryset.count(),
            'todo': queryset.filter(status='todo').count(),
            'in_progress': queryset.filter(status='in_progress').count(),
            'done': queryset.filter(status='done').count(),
        }
        return Response(stats)
```

### Code Lab: Router Configuration

**backend/apps/api/urls.py**

```python
from rest_framework.routers import DefaultRouter
from django.urls import path, include
from apps.tasks.views import TaskViewSet
from apps.projects.views import ProjectViewSet

router = DefaultRouter()
router.register(r'tasks', TaskViewSet, basename='task')
router.register(r'projects', ProjectViewSet, basename='project')

urlpatterns = router.urls
```

### Review Questions

1. What are the benefits of using ViewSets over function-based views?
2. How do you add custom actions to a ViewSet?
3. What does the router do automatically?
4. When would you use `get_serializer_class()`?

### Challenge

Create a `ProjectViewSet` with a custom action that returns statistics about the project (total tasks, completed tasks, etc.).

---

## Part 9: Advanced Querying

### Learning Objectives
- Implement filtering with django-filter
- Add search functionality
- Implement ordering
- Create custom filter methods

### Key Concepts

**Filter Types:**
| Lookup | Description |
|--------|-------------|
| `exact` | Exact match |
| `icontains` | Case-insensitive contains |
| `gte` | Greater than or equal |
| `lte` | Less than or equal |
| `in` | In a list |
| `isnull` | Is null |

### Hands-On Exercise: Create Filters

**Task 1: Create Task Filter**

```python
# backend/apps/tasks/filters.py
from django_filters import rest_framework as filters
from .models import Task

class TaskFilter(filters.FilterSet):
    status = filters.ChoiceFilter(choices=Task.Status.choices)
    priority = filters.ChoiceFilter(choices=Task.Priority.choices)
    created_after = filters.DateTimeFilter(field_name='created_at', lookup_expr='gte')
    created_before = filters.DateTimeFilter(field_name='created_at', lookup_expr='lte')
    search = filters.CharFilter(method='filter_search')
    
    class Meta:
        model = Task
        fields = ['status', 'priority', 'project', 'assigned_to']
    
    def filter_search(self, queryset, name, value):
        return queryset.filter(
            models.Q(title__icontains=value) |
            models.Q(description__icontains=value)
        )
```

**Task 2: Apply Filter to ViewSet**

```python
# backend/apps/tasks/views.py
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import filters
from .filters import TaskFilter

class TaskViewSet(viewsets.ModelViewSet):
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_class = TaskFilter
    search_fields = ['title', 'description']
    ordering_fields = ['created_at', 'due_date', 'priority', 'status']
    ordering = ['-created_at']
```

### Code Lab: Complete Filter Example

```python
class TaskFilter(filters.FilterSet):
    # Exact filters
    status = filters.ChoiceFilter(choices=Task.Status.choices)
    priority = filters.ChoiceFilter(choices=Task.Priority.choices)
    
    # Text search
    title = filters.CharFilter(field_name='title', lookup_expr='icontains')
    description = filters.CharFilter(field_name='description', lookup_expr='icontains')
    
    # Date filters
    created_after = filters.DateTimeFilter(field_name='created_at', lookup_expr='gte')
    created_before = filters.DateTimeFilter(field_name='created_at', lookup_expr='lte')
    due_after = filters.DateTimeFilter(field_name='due_date', lookup_expr='gte')
    due_before = filters.DateTimeFilter(field_name='due_date', lookup_expr='lte')
    
    # Boolean filters
    is_overdue = filters.BooleanFilter(method='filter_is_overdue')
    has_comments = filters.BooleanFilter(method='filter_has_comments')
    
    class Meta:
        model = Task
        fields = ['status', 'priority', 'project', 'assigned_to', 
                  'created_by', 'title', 'description']
    
    def filter_is_overdue(self, queryset, name, value):
        now = timezone.now()
        if value:
            return queryset.filter(
                due_date__lt=now,
                status__in=['todo', 'in_progress', 'review']
            )
        return queryset.exclude(
            due_date__lt=now,
            status__in=['todo', 'in_progress', 'review']
        )
```

### Review Questions

1. What is django-filter and why use it?
2. How do you implement search across multiple fields?
3. What is the difference between `ordering_fields` and `ordering`?
4. How do you create custom filter methods?

### Challenge

Add a `comment_count_min` and `comment_count_max` filter to the TaskFilter that filters tasks based on the number of comments.

---

## Part 10: Pagination

### Learning Objectives
- Implement page number pagination
- Create custom pagination classes
- Add pagination controls to frontend
- Implement page size selector

### Key Concepts

**Pagination Strategies:**
| Strategy | URL Pattern | Best For |
|----------|-------------|----------|
| Page Number | `?page=2&page_size=20` | Most use cases |
| Limit Offset | `?limit=20&offset=40` | Position-based |
| Cursor | `?cursor=encoded` | Infinite scrolling |

### Hands-On Exercise: Custom Pagination

**Task 1: Create Custom Pagination Class**

```python
# backend/apps/api/pagination.py
from rest_framework import pagination
from rest_framework.response import Response

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

**Task 2: Apply to Settings**

```python
# backend/config/settings.py
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'apps.api.pagination.CustomPageNumberPagination',
    'PAGE_SIZE': 20,
}
```

### Code Lab: Frontend Pagination Component

**components/ui/Pagination.tsx**

```tsx
'use client';

interface PaginationProps {
    currentPage: number;
    totalPages: number;
    onPageChange: (page: number) => void;
}

export function Pagination({ currentPage, totalPages, onPageChange }: PaginationProps) {
    if (totalPages <= 1) return null;
    
    const pages = Array.from({ length: totalPages }, (_, i) => i + 1);
    const visiblePages = pages.filter(p => 
        p === 1 || p === totalPages || Math.abs(p - currentPage) <= 2
    );
    
    return (
        <nav className="flex items-center gap-1">
            <button
                onClick={() => onPageChange(currentPage - 1)}
                disabled={currentPage === 1}
                className="px-3 py-1 border rounded disabled:opacity-50"
            >
                Previous
            </button>
            
            {visiblePages.map((page, index) => {
                if (index > 0 && page - visiblePages[index - 1] > 1) {
                    return <span key={`ellipsis-${index}`} className="px-3">…</span>;
                }
                return (
                    <button
                        key={page}
                        onClick={() => onPageChange(page)}
                        className={`px-3 py-1 rounded ${
                            page === currentPage
                                ? 'bg-blue-600 text-white'
                                : 'border hover:bg-gray-50'
                        }`}
                    >
                        {page}
                    </button>
                );
            })}
            
            <button
                onClick={() => onPageChange(currentPage + 1)}
                disabled={currentPage === totalPages}
                className="px-3 py-1 border rounded disabled:opacity-50"
            >
                Next
            </button>
        </nav>
    );
}
```

### Review Questions

1. What are the three pagination strategies in DRF?
2. How do you allow the client to set page size?
3. What information should a paginated response include?
4. How do you implement pagination on the frontend?

### Challenge

Implement infinite scrolling on the frontend using cursor pagination from the backend.

---

## Part 11: Next.js Routing & Navigation

### Learning Objectives
- Master dynamic routes
- Use route groups
- Implement nested layouts
- Add loading and error states

### Key Concepts

**Route Types:**
| Type | Pattern | Example |
|------|---------|---------|
| Static | `/about/page.tsx` | `/about` |
| Dynamic | `/[id]/page.tsx` | `/123` |
| Catch-all | `/[...slug]/page.tsx` | `/a/b/c` |
| Route Group | `/(auth)/login/page.tsx` | `/login` |

### Hands-On Exercise: Dynamic Routes

**Task 1: Create Project Detail Page**

```tsx
// app/(dashboard)/projects/[id]/page.tsx
import { get } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { Project } from '@/types';
import { notFound } from 'next/navigation';

interface ProjectPageProps {
    params: {
        id: string;
    };
}

export default async function ProjectPage({ params }: ProjectPageProps) {
    const project = await get<Project>(ENDPOINTS.projects.detail(parseInt(params.id)));
    
    if (!project) {
        notFound();
    }
    
    return (
        <div>
            <h1 className="text-2xl font-bold">{project.name}</h1>
            <p className="text-gray-600">{project.description}</p>
        </div>
    );
}
```

**Task 2: Create Loading and Error States**

```tsx
// app/(dashboard)/projects/loading.tsx
export default function Loading() {
    return (
        <div className="flex items-center justify-center min-h-[200px]">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
        </div>
    );
}

// app/(dashboard)/projects/error.tsx
'use client';

export default function Error({
    error,
    reset,
}: {
    error: Error;
    reset: () => void;
}) {
    return (
        <div className="text-center py-12">
            <h2 className="text-xl font-bold text-red-600">Something went wrong!</h2>
            <p className="text-gray-600">{error.message}</p>
            <button
                onClick={reset}
                className="mt-4 px-4 py-2 bg-blue-600 text-white rounded"
            >
                Try again
            </button>
        </div>
    );
}
```

### Code Lab: Navigation with Active State

```tsx
'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

export function Navigation() {
    const pathname = usePathname();
    
    const links = [
        { href: '/dashboard', label: 'Dashboard' },
        { href: '/projects', label: 'Projects' },
        { href: '/tasks', label: 'Tasks' },
    ];
    
    return (
        <nav className="space-y-1">
            {links.map((link) => (
                <Link
                    key={link.href}
                    href={link.href}
                    className={`block px-4 py-2 rounded ${
                        pathname === link.href || pathname?.startsWith(link.href + '/')
                            ? 'bg-blue-600 text-white'
                            : 'hover:bg-gray-700 text-gray-300'
                    }`}
                >
                    {link.label}
                </Link>
            ))}
        </nav>
    );
}
```

### Review Questions

1. What is a route group and when would you use it?
2. How do you create a dynamic route in Next.js?
3. What is the purpose of `loading.tsx` and `error.tsx`?
4. How do you implement nested layouts?

### Challenge

Create a nested layout for the projects section that includes a sidebar with project navigation and a main content area.

---

## Part 12: Frontend Data Architecture

### Learning Objectives
- Set up React Query
- Create data fetching hooks
- Implement optimistic updates
- Handle cache invalidation

### Key Concepts

**React Query Concepts:**
- **Query**: Data fetching
- **Mutation**: Data modification
- **Cache**: Stored query results
- **Invalidation**: Marking cache as stale

### Hands-On Exercise: React Query Setup

**Task 1: Create Query Provider**

```tsx
// components/providers/QueryProvider.tsx
'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import { useState } from 'react';

export function QueryProvider({ children }: { children: React.ReactNode }) {
    const [queryClient] = useState(
        () =>
            new QueryClient({
                defaultOptions: {
                    queries: {
                        staleTime: 60 * 1000,
                        gcTime: 5 * 60 * 1000,
                        retry: 1,
                        refetchOnWindowFocus: false,
                    },
                },
            })
    );
    
    return (
        <QueryClientProvider client={queryClient}>
            {children}
            {process.env.NODE_ENV === 'development' && <ReactQueryDevtools />}
        </QueryClientProvider>
    );
}
```

**Task 2: Create Data Fetching Hooks**

```tsx
// hooks/useTasks.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { get, post } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { Task } from '@/types';

export function useTasks(filters = {}) {
    return useQuery({
        queryKey: ['tasks', filters],
        queryFn: () => get<Task[]>(ENDPOINTS.tasks.list, filters),
    });
}

export function useCreateTask() {
    const queryClient = useQueryClient();
    
    return useMutation({
        mutationFn: (data: Partial<Task>) => post<Task>(ENDPOINTS.tasks.list, data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['tasks'] });
        },
    });
}
```

### Code Lab: Optimistic Updates

```tsx
// hooks/useUpdateTask.ts
export function useUpdateTask() {
    const queryClient = useQueryClient();
    
    return useMutation({
        mutationFn: ({ id, data }: { id: number; data: Partial<Task> }) =>
            patch<Task>(ENDPOINTS.tasks.detail(id), data),
        
        onMutate: async ({ id, data }) => {
            await queryClient.cancelQueries({ queryKey: ['tasks'] });
            
            const previousTasks = queryClient.getQueryData<Task[]>(['tasks']);
            
            queryClient.setQueryData<Task[]>(['tasks'], (old) =>
                old?.map((task) =>
                    task.id === id ? { ...task, ...data } : task
                )
            );
            
            return { previousTasks };
        },
        
        onError: (err, variables, context) => {
            if (context?.previousTasks) {
                queryClient.setQueryData(['tasks'], context.previousTasks);
            }
        },
        
        onSettled: () => {
            queryClient.invalidateQueries({ queryKey: ['tasks'] });
        },
    });
}
```

### Review Questions

1. What is the purpose of React Query?
2. What is the difference between `staleTime` and `gcTime`?
3. How do you implement optimistic updates?
4. Why is cache invalidation important?

### Challenge

Create a `useComments` hook that fetches comments for a specific task and supports optimistic additions.

---

## Part 13: Searchable Data Interfaces

### Learning Objectives
- Implement URL-based state management
- Build data tables with sorting
- Add search with debouncing
- Combine filters and pagination

### Key Concepts

**URL State Benefits:**
- Shareable links
- Bookmarkable views
- Browser navigation works
- Server-side state available

### Hands-On Exercise: URL State Hook

**Task 1: Create useUrlState Hook**

```tsx
// hooks/useUrlState.ts
import { useRouter, useSearchParams } from 'next/navigation';
import { useCallback, useMemo } from 'react';

export function useUrlState<T extends Record<string, any>>() {
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

**Task 2: Create Searchable Tasks Page**

```tsx
// app/(dashboard)/tasks/page.tsx
'use client';

import { useUrlState } from '@/hooks/useUrlState';
import { useTasks } from '@/hooks/useTasks';
import { DataTable } from '@/components/data/DataTable';
import { SearchBar } from '@/components/data/SearchBar';

export default function TasksPage() {
    const { state, updateState } = useUrlState<{
        search?: string;
        status?: string;
        page?: number;
        page_size?: number;
        sort?: string;
    }>();
    
    const { data, isLoading } = useTasks({
        search: state.search,
        status: state.status,
        page: state.page || 1,
        page_size: state.page_size || 20,
        ordering: state.sort,
    });
    
    return (
        <div className="space-y-4">
            <SearchBar
                value={state.search || ''}
                onChange={(value) => updateState({ search: value, page: 1 })}
                placeholder="Search tasks..."
            />
            
            <DataTable
                data={data?.results || []}
                loading={isLoading}
                onSort={(key, direction) => {
                    const sortKey = direction === 'desc' ? `-${key}` : key;
                    updateState({ sort: sortKey });
                }}
            />
            
            <Pagination
                currentPage={state.page || 1}
                totalPages={data?.total_pages || 1}
                onPageChange={(page) => updateState({ page })}
            />
        </div>
    );
}
```

### Code Lab: DataTable Component

```tsx
// components/data/DataTable.tsx
interface Column<T> {
    key: string;
    header: string;
    accessor?: (item: T) => React.ReactNode;
    sortable?: boolean;
}

interface DataTableProps<T> {
    data: T[];
    columns: Column<T>[];
    loading?: boolean;
    onSort?: (key: string, direction: 'asc' | 'desc') => void;
    sortKey?: string;
    sortDirection?: 'asc' | 'desc';
}

export function DataTable<T extends { id: string | number }>({
    data,
    columns,
    loading,
    onSort,
    sortKey,
    sortDirection,
}: DataTableProps<T>) {
    if (loading) {
        return <div className="animate-pulse">Loading...</div>;
    }
    
    return (
        <div className="overflow-x-auto">
            <table className="w-full">
                <thead>
                    <tr className="border-b border-gray-200">
                        {columns.map((column) => (
                            <th
                                key={column.key}
                                onClick={() => {
                                    if (column.sortable && onSort) {
                                        const direction = sortKey === column.key && sortDirection === 'asc'
                                            ? 'desc'
                                            : 'asc';
                                        onSort(column.key, direction);
                                    }
                                }}
                                className="px-4 py-2 text-left text-sm font-medium text-gray-600"
                            >
                                <div className="flex items-center gap-1">
                                    {column.header}
                                    {column.sortable && (
                                        <span className="text-gray-400">
                                            {sortKey === column.key
                                                ? sortDirection === 'asc' ? '↑' : '↓'
                                                : '↕'}
                                        </span>
                                    )}
                                </div>
                            </th>
                        ))}
                    </tr>
                </thead>
                <tbody>
                    {data.map((item) => (
                        <tr key={item.id} className="border-b border-gray-100">
                            {columns.map((column) => (
                                <td key={column.key} className="px-4 py-2">
                                    {column.accessor ? column.accessor(item) : (item as any)[column.key]}
                                </td>
                            ))}
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
}
```

### Review Questions

1. What are the benefits of URL-based state management?
2. How do you implement debounced search?
3. What information should a paginated response include?
4. How do you handle sorting in a data table?

### Challenge

Add filtering by status and priority to the tasks page using URL state. Implement filter dropdowns that sync with the URL.

---

## Phase 1-2 Completed Projects

### Project 1: Task Management Application

**Features to Implement:**
1. User registration and login
2. Project creation and management
3. Task creation with status and priority
4. Task assignment to users
5. Comments on tasks
6. Search and filtering
7. Pagination

**Checklist:**

- [ ] User authentication
- [ ] Project CRUD
- [ ] Task CRUD
- [ ] Task status update
- [ ] Task assignment
- [ ] Comments
- [ ] Search
- [ ] Filters
- [ ] Pagination
- [ ] Responsive UI

---

## Answer Key

### Part 1 Review Questions

1. **GET** method should be used to fetch a list of tasks.
2. **201 Created** status code should be returned when a resource is created.
3. **PUT** replaces the entire resource, while **PATCH** updates only specified fields.
4. URLs should use nouns because they represent resources (users, projects, tasks).

### Part 2 Review Questions

1. A virtual environment isolates Python dependencies for different projects.
2. A project is a collection of apps and settings; an app is a reusable component that provides specific functionality.
3. Migrations translate model changes into database schema changes.
4. A custom User model allows adding fields like `bio`, `role`, and using email as username field.

### Part 3 Review Questions

1. `ModelSerializer` automatically generates fields from a model; `Serializer` requires manual field definitions.
2. Add a `validate_<field_name>()` method to the serializer.
3. `read_only_fields` are included in the response but cannot be set in requests.
4. List views need fewer fields for performance; detail views need all fields.

### Part 4 Review Questions

1. `@api_view` is for simple function-based views; `APIView` is for class-based views with more structure.
2. 200 OK, 201 Created, 204 No Content
3. PUT requires all fields; PATCH only requires the fields being updated.
4. To return proper 404 status code and handle errors gracefully.

---

## Progress Tracker

### Phase 1: REST API & Next.js Foundations
- [ ] Part 0: Introduction
- [ ] Part 1: REST Architecture & HTTP Fundamentals
- [ ] Part 2: Django 6 Backend Foundations
- [ ] Part 3: DRF Serializers
- [ ] Part 4: Building API Views
- [ ] Part 5: Next.js 16 Foundations
- [ ] Part 6: Connecting Next.js to DRF
- [ ] Part 7: CRUD Operations Across the Stack

### Phase 2: Advanced DRF Architecture & Next.js Data Flow
- [ ] Part 8: Generic Views, ViewSets & Routers
- [ ] Part 9: Advanced Querying
- [ ] Part 10: Pagination
- [ ] Part 11: Next.js Routing & Navigation
- [ ] Part 12: Frontend Data Architecture
- [ ] Part 13: Searchable Data Interfaces

### Phase 3: Authentication, Authorization & Application Security
- [ ] Part 14: Authentication Architecture
- [ ] Part 15: JWT with SimpleJWT
- [ ] Part 16: DRF Permissions
- [ ] Part 17: Role-Based Access Control
- [ ] Part 18: Next.js Authentication
- [ ] Part 19: Next.js Request Interception
- [ ] Part 20: API Security

### Phase 4: Performance, Testing, Documentation & Production
- [ ] Part 21: Django ORM Performance
- [ ] Part 22: Redis Caching
- [ ] Part 23: API Performance
- [ ] Part 24: Automated Backend Testing
- [ ] Part 25: Frontend Testing
- [ ] Part 26: API Documentation
- [ ] Part 27: Dockerizing Django
- [ ] Part 28: Dockerizing Next.js
- [ ] Part 29: Docker Compose
- [ ] Part 30: Production Configuration
- [ ] Part 31: Reverse Proxy & Networking
- [ ] Part 32: CI/CD
- [ ] Part 33: Observability & Production Operations

---

*This concludes the Student Workbook. Use it alongside the masterclass to reinforce your learning.*
