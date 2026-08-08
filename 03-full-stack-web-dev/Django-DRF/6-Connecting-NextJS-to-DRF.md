# Part 6: Connecting Next.js to DRF

## Building the Data Layer

Welcome to **Part 6** of the Django REST Framework & Next.js 16 masterclass. Now that we have both our Django API and Next.js frontend set up, it's time to connect them. We'll build the data layer that fetches, creates, updates, and deletes data from our API.

In this part, we'll:
- Create data fetching functions for all resources
- Build forms for creating and updating data
- Handle loading and error states
- Implement optimistic updates
- Create reusable data components

Think of this as building the **plumbing** between our frontend UI and backend API. We're creating the pipes that data flows through, complete with valves (loading states), filters (error handling), and pressure gauges (validation).

---

## The Target

We'll build comprehensive data components and pages:

```
frontend/app/(dashboard)/
├── projects/
│   ├── page.tsx                    # List projects with create button
│   ├── create/
│   │   └── page.tsx                # Create project form
│   ├── [id]/
│   │   ├── page.tsx                # Project detail with tasks
│   │   ├── edit/
│   │   │   └── page.tsx            # Edit project form
│   │   └── tasks/
│   │       └── create/
│   │           └── page.tsx        # Create task in project
│   └── components/
│       ├── ProjectList.tsx
│       ├── ProjectForm.tsx
│       └── ProjectCard.tsx
├── tasks/
│   ├── page.tsx                    # List tasks with filters
│   ├── create/
│   │   └── page.tsx                # Create task form
│   ├── [id]/
│   │   ├── page.tsx                # Task detail with comments
│   │   └── edit/
│   │       └── page.tsx            # Edit task form
│   └── components/
│       ├── TaskList.tsx
│       ├── TaskForm.tsx
│       └── TaskCard.tsx
└── components/
    ├── forms/
    │   ├── ProjectForm.tsx
    │   └── TaskForm.tsx
    └── data/
        ├── DataTable.tsx
        ├── Pagination.tsx
        └── SearchBar.tsx
```

---

## The Concept

### Data Flow in Next.js

Data in Next.js flows in two directions:

1. **Server-to-Client** (reading data):
   - Server Components fetch data from the API
   - Data is rendered into HTML on the server
   - HTML is sent to the client with minimal JavaScript

2. **Client-to-Server** (writing data):
   - Client Components handle forms and user interactions
   - Data is sent to the API via fetch or API routes
   - Server revalidates and re-renders as needed

### Data Fetching Patterns

| Pattern | Where | When | Use Case |
|---------|-------|------|----------|
| Server-side | Server Component | On page load | Initial page data |
| Client-side | Client Component | On user action | Search, filters, pagination |
| Mutations | Client Component | On form submit | Create, update, delete |

### The Data Flow Cycle

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
Server Revalidates (optional)
```

### Revalidation Strategies

Next.js provides several ways to revalidate data:

1. **Time-based revalidation**: `fetch(url, { next: { revalidate: 60 } })`
2. **On-demand revalidation**: `revalidatePath()` or `revalidateTag()`
3. **Refresh**: `router.refresh()` (client-side)

We'll use a combination of these to keep our data fresh.

---

## The Implementation

### Step 1: Create Data Fetching Utilities

**frontend/lib/api/hooks.ts**
```tsx
/**
 * Custom hooks for data fetching
 * These provide a consistent pattern for loading, error, and data states
 */

'use client';

import { useState, useEffect, useCallback } from 'react';
import { get, post, put, patch, del, ApiResponse } from './client';

interface UseFetchOptions {
  enabled?: boolean;
  initialData?: any;
}

/**
 * Hook for fetching data
 */
export function useFetch<T = any>(
  url: string,
  options: UseFetchOptions = {}
) {
  const { enabled = true, initialData } = options;
  const [data, setData] = useState<T | undefined>(initialData);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  const fetchData = useCallback(async () => {
    if (!enabled) return;
    
    setLoading(true);
    setError(null);
    
    try {
      const response = await get<T>(url);
      
      if (response.error) {
        setError(response.error.detail || 'An error occurred');
      } else {
        setData(response.data);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setLoading(false);
    }
  }, [url, enabled]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const refetch = useCallback(() => {
    return fetchData();
  }, [fetchData]);

  return { data, loading, error, refetch };
}

/**
 * Hook for mutations (create, update, delete)
 */
export function useMutation<T = any, V = any>(
  url: string,
  method: 'POST' | 'PUT' | 'PATCH' | 'DELETE'
) {
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [data, setData] = useState<T | null>(null);

  const mutate = useCallback(
    async (variables?: V): Promise<ApiResponse<T>> => {
      setLoading(true);
      setError(null);
      
      try {
        let response: ApiResponse<T>;
        
        switch (method) {
          case 'POST':
            response = await post<T>(url, variables);
            break;
          case 'PUT':
            response = await put<T>(url, variables);
            break;
          case 'PATCH':
            response = await patch<T>(url, variables);
            break;
          case 'DELETE':
            response = await del<T>(url);
            break;
          default:
            throw new Error(`Unsupported method: ${method}`);
        }
        
        if (response.error) {
          setError(response.error.detail || 'An error occurred');
          return response;
        }
        
        setData(response.data || null);
        return response;
      } catch (err) {
        const message = err instanceof Error ? err.message : 'An error occurred';
        setError(message);
        return { error: { detail: message }, status: 0 };
      } finally {
        setLoading(false);
      }
    },
    [url, method]
  );

  return { mutate, loading, error, data };
}
```

### Step 2: Create Project Data Components

**frontend/app/(dashboard)/projects/components/ProjectList.tsx**
```tsx
'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { Plus, Pencil, Trash2 } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { LoadingSpinner } from '@/components/ui/LoadingSpinner';
import { useFetch, useMutation } from '@/lib/api/hooks';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { Project } from '@/types';

interface ProjectListProps {
  initialProjects?: Project[];
}

export function ProjectList({ initialProjects }: ProjectListProps) {
  const router = useRouter();
  const [showCreateForm, setShowCreateForm] = useState(false);
  
  // Fetch projects
  const { data: projects, loading, error, refetch } = useFetch<Project[]>(
    ENDPOINTS.projects.list,
    { initialData: initialProjects }
  );

  // Delete mutation
  const { mutate: deleteProject, loading: deleting } = useMutation(
    ENDPOINTS.projects.detail(0), // Placeholder, we'll set dynamically
    'DELETE'
  );

  const handleDelete = async (id: number) => {
    if (!confirm('Are you sure you want to delete this project?')) {
      return;
    }

    // Set the correct URL for deletion
    const response = await deleteProject(undefined, {
      url: ENDPOINTS.projects.detail(id),
    } as any);

    if (!response.error) {
      refetch();
      router.refresh();
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center py-12">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (error) {
    return (
      <Card>
        <CardContent className="py-6 text-center text-danger-600">
          Error loading projects: {error}
        </CardContent>
      </Card>
    );
  }

  if (!projects || projects.length === 0) {
    return (
      <Card>
        <CardContent className="py-12 text-center">
          <p className="text-secondary-500">No projects yet</p>
          <Link href="/projects/create">
            <Button className="mt-4">
              <Plus className="mr-2 h-4 w-4" />
              Create First Project
            </Button>
          </Link>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-semibold">Projects</h2>
        <Link href="/projects/create">
          <Button>
            <Plus className="mr-2 h-4 w-4" />
            New Project
          </Button>
        </Link>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {projects.map((project) => (
          <Card key={project.id} className="card-hover">
            <CardHeader>
              <div className="flex items-start justify-between">
                <Link href={`/projects/${project.id}`} className="flex-1">
                  <CardTitle className="hover:text-primary-600">
                    {project.name}
                  </CardTitle>
                </Link>
                <div className="flex gap-1">
                  <Link href={`/projects/${project.id}/edit`}>
                    <Button variant="ghost" size="sm">
                      <Pencil className="h-4 w-4" />
                    </Button>
                  </Link>
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => handleDelete(project.id)}
                    disabled={deleting}
                  >
                    <Trash2 className="h-4 w-4 text-danger-500" />
                  </Button>
                </div>
              </div>
            </CardHeader>
            <CardContent>
              {project.description && (
                <p className="text-sm text-secondary-600 line-clamp-2">
                  {project.description}
                </p>
              )}
              <div className="mt-4 flex items-center justify-between">
                <div className="flex gap-2">
                  <Badge variant="secondary">
                    {project.task_count} tasks
                  </Badge>
                  {project.completed_task_count > 0 && (
                    <Badge variant="success">
                      {project.completed_task_count} completed
                    </Badge>
                  )}
                </div>
                <span className="text-xs text-secondary-400">
                  Created by {project.created_by_username}
                </span>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
```

**frontend/app/(dashboard)/projects/components/ProjectForm.tsx**
```tsx
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Textarea } from '@/components/ui/Textarea';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { post, put } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { Project } from '@/types';

interface ProjectFormProps {
  project?: Project;
  isEditing?: boolean;
}

export function ProjectForm({ project, isEditing = false }: ProjectFormProps) {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState<Record<string, string[]>>({});

  const [name, setName] = useState(project?.name || '');
  const [description, setDescription] = useState(project?.description || '');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrors({});

    const data = { name, description: description || undefined };

    try {
      let response;
      if (isEditing && project) {
        response = await put(ENDPOINTS.projects.detail(project.id), data);
      } else {
        response = await post(ENDPOINTS.projects.list, data);
      }

      if (response.error) {
        // Handle validation errors
        if (typeof response.error === 'object') {
          setErrors(response.error as Record<string, string[]>);
        } else {
          setErrors({ general: [response.error.detail || 'An error occurred'] });
        }
        return;
      }

      // Success - redirect to projects list
      router.push('/projects');
      router.refresh();
    } catch (error) {
      setErrors({ general: ['An unexpected error occurred'] });
    } finally {
      setLoading(false);
    }
  };

  return (
    <Card className="max-w-2xl mx-auto">
      <CardHeader>
        <CardTitle>{isEditing ? 'Edit Project' : 'Create New Project'}</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* General errors */}
          {errors.general && (
            <div className="rounded-md bg-danger-50 p-3 text-sm text-danger-600">
              {errors.general.join(', ')}
            </div>
          )}

          {/* Name field */}
          <div>
            <label htmlFor="name" className="block text-sm font-medium text-secondary-700">
              Project Name *
            </label>
            <Input
              id="name"
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              required
              className="mt-1"
              placeholder="Enter project name"
            />
            {errors.name && (
              <p className="mt-1 text-sm text-danger-600">{errors.name.join(', ')}</p>
            )}
          </div>

          {/* Description field */}
          <div>
            <label htmlFor="description" className="block text-sm font-medium text-secondary-700">
              Description
            </label>
            <Textarea
              id="description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              className="mt-1"
              rows={4}
              placeholder="Describe your project..."
            />
            {errors.description && (
              <p className="mt-1 text-sm text-danger-600">{errors.description.join(', ')}</p>
            )}
          </div>

          {/* Actions */}
          <div className="flex gap-3">
            <Button
              type="submit"
              disabled={loading}
              isLoading={loading}
            >
              {isEditing ? 'Update Project' : 'Create Project'}
            </Button>
            <Button
              type="button"
              variant="outline"
              onClick={() => router.push('/projects')}
            >
              Cancel
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  );
}
```

### Step 3: Create Project Pages

**frontend/app/(dashboard)/projects/page.tsx**
```tsx
import { Metadata } from 'next';
import { ProjectList } from './components/ProjectList';
import { get } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { Project } from '@/types';

export const metadata: Metadata = {
  title: 'Projects',
  description: 'Manage your projects',
};

export default async function ProjectsPage() {
  // Server-side data fetching
  const response = await get<Project[]>(ENDPOINTS.projects.list);
  const projects = response.data || [];

  return (
    <div className="container-custom py-6">
      <ProjectList initialProjects={projects} />
    </div>
  );
}
```

**frontend/app/(dashboard)/projects/create/page.tsx**
```tsx
import { Metadata } from 'next';
import { ProjectForm } from '../components/ProjectForm';

export const metadata: Metadata = {
  title: 'Create Project',
  description: 'Create a new project',
};

export default function CreateProjectPage() {
  return (
    <div className="container-custom py-6">
      <ProjectForm />
    </div>
  );
}
```

**frontend/app/(dashboard)/projects/[id]/page.tsx**
```tsx
import { Metadata } from 'next';
import { notFound } from 'next/navigation';
import Link from 'next/link';
import { Plus } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { get } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { Project, Task } from '@/types';
import { formatDate, cn } from '@/lib/utils/helpers';
import { TASK_STATUS_LABELS, TASK_STATUS_COLORS } from '@/lib/utils/constants';

interface ProjectPageProps {
  params: {
    id: string;
  };
}

export async function generateMetadata({ params }: ProjectPageProps): Promise<Metadata> {
  const project = await getProject(params.id);
  return {
    title: project?.name || 'Project',
    description: project?.description || 'Project details',
  };
}

async function getProject(id: string): Promise<Project | null> {
  const response = await get<Project>(ENDPOINTS.projects.detail(parseInt(id)));
  if (response.error) {
    return null;
  }
  return response.data || null;
}

async function getProjectTasks(projectId: number): Promise<Task[]> {
  const response = await get<Task[]>(ENDPOINTS.projects.tasks(projectId));
  return response.data || [];
}

export default async function ProjectPage({ params }: ProjectPageProps) {
  const project = await getProject(params.id);
  
  if (!project) {
    notFound();
  }

  const tasks = await getProjectTasks(project.id);

  const completedTasks = tasks.filter(t => t.status === 'done');
  const progress = tasks.length > 0 
    ? Math.round((completedTasks.length / tasks.length) * 100)
    : 0;

  return (
    <div className="container-custom py-6">
      <div className="mb-6 flex items-start justify-between">
        <div>
          <h1 className="text-3xl font-bold">{project.name}</h1>
          {project.description && (
            <p className="mt-1 text-secondary-600">{project.description}</p>
          )}
        </div>
        <div className="flex gap-3">
          <Link href={`/projects/${project.id}/tasks/create`}>
            <Button>
              <Plus className="mr-2 h-4 w-4" />
              Add Task
            </Button>
          </Link>
          <Link href={`/projects/${project.id}/edit`}>
            <Button variant="outline">Edit Project</Button>
          </Link>
        </div>
      </div>

      {/* Stats */}
      <div className="mb-6 grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium">Total Tasks</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{tasks.length}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium">Completed</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{completedTasks.length}</div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-medium">Progress</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{progress}%</div>
            <div className="mt-2 h-2 w-full rounded-full bg-secondary-200">
              <div
                className="h-2 rounded-full bg-primary-500 transition-all"
                style={{ width: `${progress}%` }}
              />
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Task List */}
      <Card>
        <CardHeader>
          <CardTitle>Tasks</CardTitle>
        </CardHeader>
        <CardContent>
          {tasks.length === 0 ? (
            <p className="text-center text-secondary-500 py-6">
              No tasks yet. Create your first task!
            </p>
          ) : (
            <div className="space-y-2">
              {tasks.map((task) => (
                <Link
                  key={task.id}
                  href={`/tasks/${task.id}`}
                  className="block rounded-lg border border-secondary-200 p-4 hover:bg-secondary-50 transition-colors"
                >
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <h3 className="font-medium">{task.title}</h3>
                      <Badge className={cn(TASK_STATUS_COLORS[task.status])}>
                        {TASK_STATUS_LABELS[task.status]}
                      </Badge>
                    </div>
                    <div className="flex items-center gap-4 text-sm text-secondary-500">
                      {task.due_date && (
                        <span>Due: {formatDate(task.due_date)}</span>
                      )}
                      {task.assigned_to_username && (
                        <span>Assigned to: {task.assigned_to_username}</span>
                      )}
                    </div>
                  </div>
                </Link>
              ))}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
```

### Step 4: Create Task Data Components

**frontend/app/(dashboard)/tasks/components/TaskList.tsx**
```tsx
'use client';

import { useState, useMemo } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { Plus, Search, X } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Input } from '@/components/ui/Input';
import { LoadingSpinner } from '@/components/ui/LoadingSpinner';
import { useFetch, useMutation } from '@/lib/api/hooks';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { Task } from '@/types';
import { TASK_STATUS_LABELS, TASK_STATUS_COLORS, TASK_PRIORITY_LABELS, TASK_PRIORITY_COLORS } from '@/lib/utils/constants';
import { formatDate, cn } from '@/lib/utils/helpers';

interface TaskListProps {
  initialTasks?: Task[];
  projectId?: number;
}

export function TaskList({ initialTasks, projectId }: TaskListProps) {
  const router = useRouter();
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('');

  // Fetch tasks
  const url = projectId 
    ? ENDPOINTS.projects.tasks(projectId)
    : ENDPOINTS.tasks.list;
  
  const { data: tasks, loading, error, refetch } = useFetch<Task[]>(
    url,
    { initialData: initialTasks }
  );

  // Filter tasks
  const filteredTasks = useMemo(() => {
    if (!tasks) return [];
    
    return tasks.filter(task => {
      const matchesSearch = task.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                           task.description?.toLowerCase().includes(searchTerm.toLowerCase());
      const matchesStatus = !statusFilter || task.status === statusFilter;
      return matchesSearch && matchesStatus;
    });
  }, [tasks, searchTerm, statusFilter]);

  // Get unique statuses for filter
  const statuses = useMemo(() => {
    if (!tasks) return [];
    return [...new Set(tasks.map(t => t.status))];
  }, [tasks]);

  if (loading) {
    return (
      <div className="flex justify-center py-12">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (error) {
    return (
      <Card>
        <CardContent className="py-6 text-center text-danger-600">
          Error loading tasks: {error}
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <h2 className="text-2xl font-semibold">Tasks</h2>
        <Link href={projectId ? `/projects/${projectId}/tasks/create` : '/tasks/create'}>
          <Button>
            <Plus className="mr-2 h-4 w-4" />
            New Task
          </Button>
        </Link>
      </div>

      {/* Filters */}
      <div className="flex flex-col gap-3 sm:flex-row">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-secondary-400" />
          <Input
            type="text"
            placeholder="Search tasks..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="pl-9"
          />
          {searchTerm && (
            <button
              onClick={() => setSearchTerm('')}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-secondary-400 hover:text-secondary-600"
            >
              <X className="h-4 w-4" />
            </button>
          )}
        </div>
        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className="rounded-md border border-secondary-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
        >
          <option value="">All Statuses</option>
          {statuses.map(status => (
            <option key={status} value={status}>
              {TASK_STATUS_LABELS[status]}
            </option>
          ))}
        </select>
        {statusFilter && (
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setStatusFilter('')}
          >
            Clear Filter
          </Button>
        )}
      </div>

      {/* Task List */}
      {filteredTasks.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center">
            <p className="text-secondary-500">
              {tasks?.length === 0 ? 'No tasks yet' : 'No tasks match your filters'}
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-2">
          {filteredTasks.map((task) => (
            <Link
              key={task.id}
              href={`/tasks/${task.id}`}
              className="block rounded-lg border border-secondary-200 bg-white p-4 hover:shadow-md transition-shadow"
            >
              <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
                <div className="flex flex-wrap items-center gap-2">
                  <h3 className="font-medium">{task.title}</h3>
                  <Badge className={cn(TASK_STATUS_COLORS[task.status])}>
                    {TASK_STATUS_LABELS[task.status]}
                  </Badge>
                  <Badge className={cn(TASK_PRIORITY_COLORS[task.priority])}>
                    {TASK_PRIORITY_LABELS[task.priority]}
                  </Badge>
                </div>
                <div className="flex flex-wrap items-center gap-4 text-sm text-secondary-500">
                  <span>Project: {task.project_name}</span>
                  {task.due_date && (
                    <span>Due: {formatDate(task.due_date)}</span>
                  )}
                  {task.assigned_to_username && (
                    <span>Assigned to: {task.assigned_to_username}</span>
                  )}
                </div>
              </div>
              {task.description && (
                <p className="mt-2 text-sm text-secondary-600 line-clamp-2">
                  {task.description}
                </p>
              )}
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
```

### Step 5: Create Task Pages

**frontend/app/(dashboard)/tasks/page.tsx**
```tsx
import { Metadata } from 'next';
import { TaskList } from './components/TaskList';
import { get } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { Task } from '@/types';

export const metadata: Metadata = {
  title: 'Tasks',
  description: 'Manage your tasks',
};

export default async function TasksPage() {
  const response = await get<Task[]>(ENDPOINTS.tasks.list);
  const tasks = response.data || [];

  return (
    <div className="container-custom py-6">
      <TaskList initialTasks={tasks} />
    </div>
  );
}
```

**frontend/app/(dashboard)/tasks/[id]/page.tsx**
```tsx
import { Metadata } from 'next';
import { notFound } from 'next/navigation';
import Link from 'next/link';
import { get } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { Task, Comment } from '@/types';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Button } from '@/components/ui/Button';
import { formatDateTime, cn } from '@/lib/utils/helpers';
import { TASK_STATUS_LABELS, TASK_STATUS_COLORS, TASK_PRIORITY_LABELS, TASK_PRIORITY_COLORS } from '@/lib/utils/constants';
import { CommentList } from './components/CommentList';

interface TaskPageProps {
  params: {
    id: string;
  };
}

export async function generateMetadata({ params }: TaskPageProps): Promise<Metadata> {
  const task = await getTask(params.id);
  return {
    title: task?.title || 'Task',
    description: task?.description || 'Task details',
  };
}

async function getTask(id: string): Promise<Task | null> {
  const response = await get<Task>(ENDPOINTS.tasks.detail(parseInt(id)));
  if (response.error) {
    return null;
  }
  return response.data || null;
}

async function getTaskComments(taskId: number): Promise<Comment[]> {
  const response = await get<Comment[]>(ENDPOINTS.tasks.comments(taskId));
  return response.data || [];
}

export default async function TaskPage({ params }: TaskPageProps) {
  const task = await getTask(params.id);
  
  if (!task) {
    notFound();
  }

  const comments = await getTaskComments(task.id);

  return (
    <div className="container-custom py-6">
      <div className="mb-6 flex items-start justify-between">
        <div>
          <h1 className="text-3xl font-bold">{task.title}</h1>
          <div className="mt-2 flex flex-wrap gap-2">
            <Badge className={cn(TASK_STATUS_COLORS[task.status])}>
              {TASK_STATUS_LABELS[task.status]}
            </Badge>
            <Badge className={cn(TASK_PRIORITY_COLORS[task.priority])}>
              {TASK_PRIORITY_LABELS[task.priority]}
            </Badge>
            {task.is_overdue && (
              <Badge variant="destructive">Overdue</Badge>
            )}
          </div>
        </div>
        <div className="flex gap-3">
          <Link href={`/tasks/${task.id}/edit`}>
            <Button>Edit Task</Button>
          </Link>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        {/* Main content */}
        <div className="lg:col-span-2 space-y-6">
          {/* Description */}
          {task.description && (
            <Card>
              <CardHeader>
                <CardTitle>Description</CardTitle>
              </CardHeader>
              <CardContent>
                <p className="whitespace-pre-wrap">{task.description}</p>
              </CardContent>
            </Card>
          )}

          {/* Comments */}
          <Card>
            <CardHeader>
              <CardTitle>Comments ({comments.length})</CardTitle>
            </CardHeader>
            <CardContent>
              <CommentList taskId={task.id} initialComments={comments} />
            </CardContent>
          </Card>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Details</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <div>
                <p className="text-sm text-secondary-500">Project</p>
                <Link href={`/projects/${task.project}`} className="font-medium hover:text-primary-600">
                  {task.project_name}
                </Link>
              </div>
              {task.assigned_to && (
                <div>
                  <p className="text-sm text-secondary-500">Assigned To</p>
                  <p className="font-medium">{task.assigned_to_username}</p>
                </div>
              )}
              {task.due_date && (
                <div>
                  <p className="text-sm text-secondary-500">Due Date</p>
                  <p className="font-medium">{formatDateTime(task.due_date)}</p>
                </div>
              )}
              <div>
                <p className="text-sm text-secondary-500">Created By</p>
                <p className="font-medium">{task.created_by_username}</p>
              </div>
              <div>
                <p className="text-sm text-secondary-500">Created At</p>
                <p className="font-medium">{formatDateTime(task.created_at)}</p>
              </div>
              <div>
                <p className="text-sm text-secondary-500">Last Updated</p>
                <p className="font-medium">{formatDateTime(task.updated_at)}</p>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
```

**frontend/app/(dashboard)/tasks/[id]/components/CommentList.tsx**
```tsx
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/Button';
import { Textarea } from '@/components/ui/Textarea';
import { LoadingSpinner } from '@/components/ui/LoadingSpinner';
import { useFetch, useMutation } from '@/lib/api/hooks';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { Comment } from '@/types';
import { formatRelativeTime } from '@/lib/utils/helpers';

interface CommentListProps {
  taskId: number;
  initialComments?: Comment[];
}

export function CommentList({ taskId, initialComments }: CommentListProps) {
  const router = useRouter();
  const [content, setContent] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [errors, setErrors] = useState<Record<string, string[]>>({});

  // Fetch comments
  const { data: comments, loading, error, refetch } = useFetch<Comment[]>(
    ENDPOINTS.tasks.comments(taskId),
    { initialData: initialComments }
  );

  // Create comment mutation
  const { mutate: createComment } = useMutation(
    ENDPOINTS.comments.list,
    'POST'
  );

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!content.trim()) return;

    setSubmitting(true);
    setErrors({});

    const response = await createComment({
      content: content.trim(),
      task: taskId,
    });

    if (response.error) {
      if (typeof response.error === 'object') {
        setErrors(response.error as Record<string, string[]>);
      } else {
        setErrors({ general: [response.error.detail || 'An error occurred'] });
      }
      setSubmitting(false);
      return;
    }

    // Success
    setContent('');
    setSubmitting(false);
    refetch();
    router.refresh();
  };

  if (loading && !initialComments) {
    return (
      <div className="flex justify-center py-6">
        <LoadingSpinner />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Comment list */}
      <div className="space-y-4">
        {comments?.length === 0 ? (
          <p className="text-center text-secondary-500 py-4">
            No comments yet. Be the first to comment!
          </p>
        ) : (
          comments?.map((comment) => (
            <div
              key={comment.id}
              className="border-b border-secondary-100 last:border-0 pb-4 last:pb-0"
            >
              <div className="flex items-start justify-between">
                <div>
                  <p className="font-medium">{comment.author_username}</p>
                  <p className="text-sm text-secondary-500">
                    {formatRelativeTime(comment.created_at)}
                  </p>
                </div>
              </div>
              <p className="mt-1 whitespace-pre-wrap">{comment.content}</p>
            </div>
          ))
        )}
      </div>

      {/* Comment form */}
      <form onSubmit={handleSubmit} className="space-y-3">
        {errors.general && (
          <div className="rounded-md bg-danger-50 p-3 text-sm text-danger-600">
            {errors.general.join(', ')}
          </div>
        )}
        
        <Textarea
          value={content}
          onChange={(e) => setContent(e.target.value)}
          placeholder="Add a comment..."
          rows={3}
          disabled={submitting}
          className="resize-none"
        />
        {errors.content && (
          <p className="text-sm text-danger-600">{errors.content.join(', ')}</p>
        )}

        <div className="flex justify-end">
          <Button
            type="submit"
            disabled={!content.trim() || submitting}
            isLoading={submitting}
          >
            Post Comment
          </Button>
        </div>
      </form>
    </div>
  );
}
```

### Step 6: Add UI Component Placeholders

Since we referenced Input and Textarea components, let's create them:

**frontend/components/ui/Input.tsx**
```tsx
import * as React from 'react';
import { cn } from '@/lib/utils/helpers';

export interface InputProps
  extends React.InputHTMLAttributes<HTMLInputElement> {}

const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ className, type, ...props }, ref) => {
    return (
      <input
        type={type}
        className={cn(
          'flex h-10 w-full rounded-md border border-secondary-300 bg-white px-3 py-2 text-sm ring-offset-white file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-secondary-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50',
          className
        )}
        ref={ref}
        {...props}
      />
    );
  }
);
Input.displayName = 'Input';

export { Input };
```

**frontend/components/ui/Textarea.tsx**
```tsx
import * as React from 'react';
import { cn } from '@/lib/utils/helpers';

export interface TextareaProps
  extends React.TextareaHTMLAttributes<HTMLTextAreaElement> {}

const Textarea = React.forwardRef<HTMLTextAreaElement, TextareaProps>(
  ({ className, ...props }, ref) => {
    return (
      <textarea
        className={cn(
          'flex min-h-[80px] w-full rounded-md border border-secondary-300 bg-white px-3 py-2 text-sm ring-offset-white placeholder:text-secondary-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50',
          className
        )}
        ref={ref}
        {...props}
      />
    );
  }
);
Textarea.displayName = 'Textarea';

export { Textarea };
```

---

## The Verification

### Step 1: Start Both Servers

**Terminal 1 (Backend):**
```bash
cd backend
source venv/bin/activate
python manage.py runserver
```

**Terminal 2 (Frontend):**
```bash
cd frontend
npm run dev
```

### Step 2: Test Project CRUD

1. **List Projects**: Go to http://localhost:3000/dashboard -> Projects
   - Should show all projects from API

2. **Create Project**: Click "New Project" -> Fill in form -> Submit
   - Should redirect to projects list with new project visible

3. **View Project**: Click a project name
   - Should show project details with task list

4. **Edit Project**: Click "Edit" -> Update fields -> Submit
   - Should show updated project

5. **Delete Project**: Click trash icon -> Confirm
   - Should remove project from list

### Step 3: Test Task CRUD

1. **List Tasks**: Go to http://localhost:3000/dashboard -> Tasks
   - Should show all tasks with filters

2. **Create Task**: Click "New Task" -> Fill in form -> Submit
   - Should redirect to tasks list with new task visible

3. **View Task**: Click a task title
   - Should show task details with comments

4. **Add Comment**: Type a comment -> Click "Post Comment"
   - Should appear in comment list

5. **Search Tasks**: Type in search box
   - Should filter tasks by title/description

6. **Filter Tasks**: Select a status filter
   - Should show only tasks with that status

### Step 4: Check API Integration

Open browser developer tools (F12) -> Network tab:

1. **Page Load**: Should see requests to:
   - `/api/v1/projects/`
   - `/api/v1/tasks/`

2. **Create Project**: Should see POST request to `/api/v1/projects/`

3. **Create Task**: Should see POST request to `/api/v1/tasks/`

4. **Add Comment**: Should see POST request to `/api/v1/comments/`

### Step 5: Test Error Handling

1. **Create Project with empty name**:
   - Should show validation errors
   - Should not redirect

2. **Create Task without project**:
   - Should show validation error for project field

3. **Delete project with tasks**:
   - Should show cascade delete warning or error (depending on model)

---

## Key Takeaways

1. **Server Components** fetch data on the server for fast initial page loads and SEO.

2. **Client Components** handle interactivity, forms, and real-time updates.

3. **Custom hooks** (useFetch, useMutation) provide consistent data fetching patterns.

4. **Form handling** includes validation, error display, and loading states.

5. **Optimistic UI** can be implemented but we used simple loading states for clarity.

6. **Error handling** at both API level (validation errors) and network level.

7. **Revalidation** keeps data fresh after mutations (router.refresh).

---

## Common Patterns

### Server Component Data Fetching
```tsx
// Server Component
export default async function Page() {
  const data = await fetchData();
  return <Component initialData={data} />;
}
```

### Client Component with useFetch
```tsx
'use client';

export function Component() {
  const { data, loading, error, refetch } = useFetch('/api/data');
  // ... render based on state
}
```

### Mutation with useMutation
```tsx
'use client';

const { mutate, loading } = useMutation('/api/data', 'POST');

const handleSubmit = async () => {
  const response = await mutate(formData);
  if (!response.error) {
    // Success!
  }
};
```

---

## What's Next

In **Part 7**, we'll complete Phase 1 by implementing the full CRUD operations across the stack. You'll learn:

- Complete create, read, update, delete for all resources
- Form validation and error handling
- Optimistic updates for better UX
- Pagination for large datasets
- Search and filtering

We'll bring everything together into a working application!

---

**End of Part 6**

*Next: Part 7 - CRUD Operations Across the Stack*
