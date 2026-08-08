# Appendix U: Django & Next.js Integration Patterns

## Comprehensive Guide to Backend-Frontend Integration

Welcome to **Appendix U** of the Django REST Framework & Next.js 16 masterclass. This appendix provides a comprehensive guide to integration patterns between Django and Next.js, including data fetching strategies, state management, and performance optimization.

---

## Section 1: Data Fetching Strategies

### 1.1 Server-Side Fetching (Next.js Server Components)

```tsx
// app/tasks/page.tsx
import { getTasks } from '@/lib/api/server';

export default async function TasksPage() {
    // Server-side fetching - runs on the server
    const tasks = await getTasks({
        status: 'todo',
        limit: 20,
    });
    
    // Server-side rendering with data
    return (
        <div>
            <h1>Tasks</h1>
            <TaskList initialTasks={tasks} />
        </div>
    );
}
```

### 1.2 Client-Side Fetching (useEffect)

```tsx
'use client';

import { useEffect, useState } from 'react';
import { getTasks } from '@/lib/api/client';

export function TaskList() {
    const [tasks, setTasks] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const fetchTasks = async () => {
            try {
                const data = await getTasks();
                setTasks(data);
            } catch (err) {
                setError(err.message);
            } finally {
                setLoading(false);
            }
        };
        
        fetchTasks();
    }, []);

    if (loading) return <LoadingSpinner />;
    if (error) return <ErrorMessage error={error} />;
    
    return <TaskItems tasks={tasks} />;
}
```

### 1.3 React Query Integration

```tsx
'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { getTasks, createTask, updateTask, deleteTask } from '@/lib/api/client';

export function useTasks(filters = {}) {
    return useQuery({
        queryKey: ['tasks', filters],
        queryFn: () => getTasks(filters),
        staleTime: 60 * 1000, // 1 minute
    });
}

export function useTask(id) {
    return useQuery({
        queryKey: ['task', id],
        queryFn: () => getTask(id),
        enabled: !!id,
    });
}

export function useCreateTask() {
    const queryClient = useQueryClient();
    
    return useMutation({
        mutationFn: createTask,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['tasks'] });
        },
    });
}

// Usage in component
function TaskManager() {
    const { data: tasks, isLoading } = useTasks({ status: 'todo' });
    const createTaskMutation = useCreateTask();
    
    const handleCreate = async (data) => {
        await createTaskMutation.mutateAsync(data);
    };
    
    // ... render
}
```

---

## Section 2: Authentication Patterns

### 2.1 JWT Authentication Flow

```tsx
// lib/auth/AuthContext.tsx
'use client';

import { createContext, useContext, useState, useCallback } from 'react';
import { login as apiLogin, logout as apiLogout, refreshToken } from '@/lib/api/auth';

interface AuthContextType {
    user: User | null;
    token: string | null;
    login: (email: string, password: string) => Promise<void>;
    logout: () => void;
    refresh: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
    const [user, setUser] = useState<User | null>(null);
    const [token, setToken] = useState<string | null>(null);
    
    const login = useCallback(async (email: string, password: string) => {
        const response = await apiLogin(email, password);
        setUser(response.user);
        setToken(response.access);
        localStorage.setItem('access_token', response.access);
        localStorage.setItem('refresh_token', response.refresh);
    }, []);
    
    const logout = useCallback(() => {
        setUser(null);
        setToken(null);
        localStorage.removeItem('access_token');
        localStorage.removeItem('refresh_token');
    }, []);
    
    const refresh = useCallback(async () => {
        try {
            const refresh = localStorage.getItem('refresh_token');
            if (!refresh) throw new Error('No refresh token');
            const response = await refreshToken(refresh);
            setToken(response.access);
            localStorage.setItem('access_token', response.access);
        } catch (error) {
            logout();
        }
    }, [logout]);
    
    return (
        <AuthContext.Provider value={{ user, token, login, logout, refresh }}>
            {children}
        </AuthContext.Provider>
    );
}

export function useAuth() {
    const context = useContext(AuthContext);
    if (!context) throw new Error('useAuth must be used within AuthProvider');
    return context;
}
```

### 2.2 Protected Routes (Next.js Middleware)

```tsx
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

const publicPaths = ['/', '/login', '/register'];
const protectedPaths = ['/dashboard', '/projects', '/tasks'];

export function middleware(request: NextRequest) {
    const token = request.cookies.get('access_token');
    const path = request.nextUrl.pathname;
    
    // Check if path is public
    const isPublic = publicPaths.some(p => path.startsWith(p));
    
    // Check if path is protected
    const isProtected = protectedPaths.some(p => path.startsWith(p));
    
    // Redirect to login if accessing protected path without token
    if (isProtected && !token) {
        return NextResponse.redirect(new URL('/login', request.url));
    }
    
    // Redirect to dashboard if accessing public path with token
    if (isPublic && token && path !== '/') {
        return NextResponse.redirect(new URL('/dashboard', request.url));
    }
    
    return NextResponse.next();
}

export const config = {
    matcher: ['/((?!_next/static|_next/image|favicon.ico|public).*)'],
};
```

### 2.3 API Client with Token Interceptor

```tsx
// lib/api/client.ts
import axios from 'axios';

const api = axios.create({
    baseURL: process.env.NEXT_PUBLIC_API_URL,
    headers: {
        'Content-Type': 'application/json',
    },
});

// Request interceptor
api.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem('access_token');
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
    },
    (error) => Promise.reject(error)
);

// Response interceptor (token refresh)
api.interceptors.response.use(
    (response) => response,
    async (error) => {
        const originalRequest = error.config;
        
        if (error.response?.status === 401 && !originalRequest._retry) {
            originalRequest._retry = true;
            
            try {
                const refresh = localStorage.getItem('refresh_token');
                const response = await axios.post(`${api.defaults.baseURL}/token/refresh/`, {
                    refresh,
                });
                
                const { access } = response.data;
                localStorage.setItem('access_token', access);
                originalRequest.headers.Authorization = `Bearer ${access}`;
                
                return api(originalRequest);
            } catch (refreshError) {
                // Redirect to login
                window.location.href = '/login';
                return Promise.reject(refreshError);
            }
        }
        
        return Promise.reject(error);
    }
);

export default api;
```

---

## Section 3: Data Synchronization Patterns

### 3.1 Optimistic Updates

```tsx
'use client';

import { useMutation, useQueryClient } from '@tanstack/react-query';
import { updateTask } from '@/lib/api/tasks';

export function useUpdateTaskOptimistic() {
    const queryClient = useQueryClient();
    
    return useMutation({
        mutationFn: updateTask,
        
        onMutate: async (newTask) => {
            // Cancel outgoing refetches
            await queryClient.cancelQueries({ queryKey: ['tasks'] });
            
            // Snapshot previous value
            const previousTasks = queryClient.getQueryData(['tasks']);
            
            // Optimistically update
            queryClient.setQueryData(['tasks'], (old: any) => {
                if (!old) return { results: [newTask] };
                return {
                    ...old,
                    results: old.results.map((task: Task) =>
                        task.id === newTask.id ? newTask : task
                    ),
                };
            });
            
            // Return context for rollback
            return { previousTasks };
        },
        
        onError: (err, newTask, context) => {
            // Rollback on error
            queryClient.setQueryData(['tasks'], context?.previousTasks);
        },
        
        onSettled: () => {
            // Refetch after error or success
            queryClient.invalidateQueries({ queryKey: ['tasks'] });
        },
    });
}
```

### 3.2 Server-Side Revalidation

```tsx
// app/actions/revalidate.ts
'use server';

import { revalidatePath, revalidateTag } from 'next/cache';

export async function revalidateTasks() {
    revalidateTag('tasks');
    revalidatePath('/tasks');
}

export async function revalidateProject(projectId: number) {
    revalidateTag(`project-${projectId}`);
    revalidatePath(`/projects/${projectId}`);
}

// Usage in API route
// app/api/tasks/route.ts
import { revalidateTag } from 'next/cache';

export async function POST(request: Request) {
    const data = await request.json();
    const task = await createTask(data);
    
    revalidateTag('tasks');
    revalidateTag(`project-${task.projectId}`);
    
    return NextResponse.json(task);
}
```

### 3.3 Real-Time Updates (WebSockets)

```tsx
// lib/websocket/client.ts
class WebSocketClient {
    private ws: WebSocket | null = null;
    private reconnectAttempts = 0;
    private maxReconnectAttempts = 5;
    
    constructor(private url: string) {}
    
    connect() {
        this.ws = new WebSocket(this.url);
        
        this.ws.onopen = () => {
            console.log('WebSocket connected');
            this.reconnectAttempts = 0;
        };
        
        this.ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            this.handleMessage(data);
        };
        
        this.ws.onclose = () => {
            this.reconnect();
        };
    }
    
    private reconnect() {
        if (this.reconnectAttempts < this.maxReconnectAttempts) {
            this.reconnectAttempts++;
            setTimeout(() => this.connect(), 1000 * this.reconnectAttempts);
        }
    }
    
    private handleMessage(data: any) {
        // Dispatch to appropriate handlers
        if (data.type === 'task_updated') {
            // Update task in cache
        }
    }
}

// Usage in React component
'use client';

import { useEffect } from 'react';
import { useQueryClient } from '@tanstack/react-query';

export function useWebSocket() {
    const queryClient = useQueryClient();
    
    useEffect(() => {
        const ws = new WebSocketClient('ws://localhost:8000/ws/');
        ws.connect();
        
        // Subscribe to updates
        ws.on('task_updated', (data) => {
            queryClient.setQueryData(['task', data.id], data);
            queryClient.invalidateQueries({ queryKey: ['tasks'] });
        });
        
        return () => ws.disconnect();
    }, [queryClient]);
}
```

---

## Section 4: Form Handling Patterns

### 4.1 Form with Server Actions

```tsx
// app/actions/task.ts
'use server';

import { revalidatePath } from 'next/cache';
import { createTask } from '@/lib/api/tasks';
import { z } from 'zod';

const taskSchema = z.object({
    title: z.string().min(3),
    description: z.string().optional(),
    project: z.number(),
    status: z.enum(['todo', 'in_progress', 'done']),
});

export async function createTaskAction(data: FormData) {
    const rawData = {
        title: data.get('title'),
        description: data.get('description'),
        project: Number(data.get('project')),
        status: data.get('status'),
    };
    
    try {
        const validated = taskSchema.parse(rawData);
        await createTask(validated);
        revalidatePath('/tasks');
        return { success: true };
    } catch (error) {
        return { 
            success: false, 
            errors: error.errors 
        };
    }
}
```

### 4.2 Form with React Hook Form

```tsx
'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useCreateTask } from '@/hooks/useTasks';

const schema = z.object({
    title: z.string().min(3, 'Title must be at least 3 characters'),
    description: z.string().optional(),
    project: z.number().positive('Project is required'),
    status: z.enum(['todo', 'in_progress', 'done']),
});

type FormData = z.infer<typeof schema>;

export function TaskForm() {
    const { register, handleSubmit, formState: { errors } } = useForm<FormData>({
        resolver: zodResolver(schema),
    });
    
    const createTask = useCreateTask();
    
    const onSubmit = async (data: FormData) => {
        await createTask.mutateAsync(data);
    };
    
    return (
        <form onSubmit={handleSubmit(onSubmit)}>
            <input {...register('title')} placeholder="Title" />
            {errors.title && <span>{errors.title.message}</span>}
            
            <textarea {...register('description')} placeholder="Description" />
            
            <select {...register('project', { valueAsNumber: true })}>
                <option value="">Select Project</option>
                {/* Project options */}
            </select>
            {errors.project && <span>{errors.project.message}</span>}
            
            <select {...register('status')}>
                <option value="todo">To Do</option>
                <option value="in_progress">In Progress</option>
                <option value="done">Done</option>
            </select>
            
            <button type="submit" disabled={createTask.isPending}>
                {createTask.isPending ? 'Creating...' : 'Create Task'}
            </button>
        </form>
    );
}
```

---

## Section 5: File Upload Patterns

### 5.1 Django Backend (DRF)

```python
# serializers.py
from rest_framework import serializers

class FileUploadSerializer(serializers.Serializer):
    file = serializers.FileField()
    name = serializers.CharField(max_length=255)
    description = serializers.CharField(required=False)

# views.py
from rest_framework.views import APIView
from rest_framework.parsers import MultiPartParser, FormParser

class FileUploadView(APIView):
    parser_classes = [MultiPartParser, FormParser]
    
    def post(self, request, *args, **kwargs):
        serializer = FileUploadSerializer(data=request.data)
        if serializer.is_valid():
            file = serializer.validated_data['file']
            # Process file
            return Response({'message': 'File uploaded successfully'})
        return Response(serializer.errors, status=400)
```

### 5.2 Next.js Frontend

```tsx
'use client';

import { useState } from 'react';
import { uploadFile } from '@/lib/api/files';

export function FileUpload() {
    const [file, setFile] = useState<File | null>(null);
    const [uploading, setUploading] = useState(false);
    
    const handleUpload = async () => {
        if (!file) return;
        
        setUploading(true);
        const formData = new FormData();
        formData.append('file', file);
        
        try {
            await uploadFile(formData);
            alert('File uploaded successfully!');
        } catch (error) {
            alert('Upload failed');
        } finally {
            setUploading(false);
        }
    };
    
    return (
        <div>
            <input
                type="file"
                onChange={(e) => setFile(e.target.files?.[0] || null)}
            />
            <button onClick={handleUpload} disabled={!file || uploading}>
                {uploading ? 'Uploading...' : 'Upload'}
            </button>
        </div>
    );
}
```

---

## Section 6: Error Handling Patterns

### 6.1 Global Error Boundary

```tsx
// components/ErrorBoundary.tsx
'use client';

import { Component, ReactNode } from 'react';

interface Props {
    children: ReactNode;
    fallback?: ReactNode;
}

interface State {
    hasError: boolean;
    error: Error | null;
}

export class ErrorBoundary extends Component<Props, State> {
    constructor(props: Props) {
        super(props);
        this.state = { hasError: false, error: null };
    }
    
    static getDerivedStateFromError(error: Error) {
        return { hasError: true, error };
    }
    
    componentDidCatch(error: Error, errorInfo: any) {
        console.error('Error caught by boundary:', error, errorInfo);
        // Send to error tracking service
    }
    
    render() {
        if (this.state.hasError) {
            return this.props.fallback || (
                <div className="error-container">
                    <h2>Something went wrong</h2>
                    <p>{this.state.error?.message}</p>
                    <button onClick={() => this.setState({ hasError: false, error: null })}>
                        Try again
                    </button>
                </div>
            );
        }
        
        return this.props.children;
    }
}
```

### 6.2 API Error Handling

```tsx
// lib/api/errors.ts
export class ApiError extends Error {
    status: number;
    data?: any;
    
    constructor(message: string, status: number, data?: any) {
        super(message);
        this.name = 'ApiError';
        this.status = status;
        this.data = data;
    }
}

// lib/api/client.ts
export async function apiRequest<T>(
    endpoint: string,
    options: RequestInit = {}
): Promise<T> {
    try {
        const response = await fetch(endpoint, {
            ...options,
            headers: {
                'Content-Type': 'application/json',
                ...options.headers,
            },
        });
        
        const data = await response.json();
        
        if (!response.ok) {
            throw new ApiError(
                data.detail || 'An error occurred',
                response.status,
                data
            );
        }
        
        return data as T;
    } catch (error) {
        if (error instanceof ApiError) {
            throw error;
        }
        throw new ApiError('Network error', 0);
    }
}
```

---

## Section 7: Integration Patterns Reference

| Pattern | Use Case | Implementation |
|---------|----------|----------------|
| **Server Fetching** | Initial page data | Server Components with async/await |
| **Client Fetching** | Dynamic updates | React Query, SWR, useEffect |
| **Authentication** | User sessions | JWT, Context API, Middleware |
| **Optimistic Updates** | Better UX | React Query optimistic mutations |
| **Real-Time Updates** | Live data | WebSockets, Server-Sent Events |
| **File Uploads** | Media files | FormData, Multipart parser |
| **Form Handling** | User input | React Hook Form, Zod |
| **Error Handling** | Robustness | Error boundaries, try/catch |
| **Caching** | Performance | React Query, SWR, server caching |

---

*This concludes Appendix U. Use these integration patterns to build robust Django + Next.js applications.*
