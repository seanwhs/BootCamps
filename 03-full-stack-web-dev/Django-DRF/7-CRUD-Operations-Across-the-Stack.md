# Part 7: CRUD Operations Across the Stack

## Completing the Full Data Flow

Welcome to **Part 7** of the Django REST Framework & Next.js 16 masterclass. This is the final part of Phase 1, where we'll complete the full CRUD (Create, Read, Update, Delete) operations across our entire stack. We'll build the remaining components, implement task creation within projects, complete the edit workflows, and add proper error handling and user feedback.

In this part, we'll:
- Complete task creation with project context
- Build task edit and update functionality
- Implement project task creation from project detail page
- Add toast notifications for user feedback
- Create delete confirmation modals
- Implement optimistic updates for better UX
- Build a complete task status update mechanism

Think of this as putting the **final touches** on our application's foundation. Everything will be connected, every operation will work, and users will have a smooth experience creating, viewing, updating, and deleting data across our entire platform.

---

## The Target

We'll complete the remaining components and pages:

```
frontend/app/(dashboard)/
├── projects/
│   └── [id]/
│       └── tasks/
│           └── create/
│               └── page.tsx        # Create task within project
├── tasks/
│   ├── [id]/
│   │   ├── edit/
│   │   │   └── page.tsx            # Edit task
│   │   └── components/
│   │       └── TaskStatusUpdate.tsx # Quick status update
│   └── components/
│       └── TaskForm.tsx            # Reusable task form
├── components/
│   ├── ui/
│   │   ├── Toast.tsx               # Toast notifications
│   │   └── Modal.tsx               # Confirmation modal
│   └── providers/
│       └── ToastProvider.tsx       # Toast context provider
└── lib/
    └── context/
        └── ToastContext.tsx        # Toast state management
```

---

## The Concept

### CRUD Operations Overview

CRUD operations represent the four basic functions of persistent storage:

| Operation | HTTP Method | Endpoint | Description |
|-----------|-------------|----------|-------------|
| **Create** | POST | `/api/resource/` | Create a new resource |
| **Read** | GET | `/api/resource/` or `/api/resource/{id}/` | List or retrieve resources |
| **Update** | PUT/PATCH | `/api/resource/{id}/` | Update an existing resource |
| **Delete** | DELETE | `/api/resource/{id}/` | Delete a resource |

### The Data Flow for Each Operation

**Create Flow:**
```
User fills form → Client validates → POST to API → Server validates → Saves to DB → Returns created resource → Client updates UI
```

**Read Flow:**
```
User navigates → Client fetches data → GET to API → Server queries DB → Returns data → Client renders UI
```

**Update Flow:**
```
User modifies data → Client validates → PUT/PATCH to API → Server validates → Updates DB → Returns updated resource → Client updates UI
```

**Delete Flow:**
```
User confirms delete → DELETE to API → Server checks permissions → Deletes from DB → Returns confirmation → Client removes from UI
```

### Optimistic Updates

Optimistic updates update the UI immediately before the server confirms the operation. This makes the app feel faster and more responsive.

**Flow:**
```
User action → Update UI immediately → Send request to server → If success, keep update → If error, rollback
```

We'll implement this pattern for status updates and deletions.

---

## The Implementation

### Step 1: Create the Toast Notification System

**frontend/lib/context/ToastContext.tsx**
```tsx
'use client';

import React, { createContext, useContext, useState, useCallback } from 'react';

export type ToastType = 'success' | 'error' | 'warning' | 'info';

export interface Toast {
  id: string;
  message: string;
  type: ToastType;
  duration?: number;
}

interface ToastContextType {
  toasts: Toast[];
  addToast: (message: string, type: ToastType, duration?: number) => void;
  removeToast: (id: string) => void;
  clearToasts: () => void;
}

const ToastContext = createContext<ToastContextType | undefined>(undefined);

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [toasts, setToasts] = useState<Toast[]>([]);

  const addToast = useCallback((message: string, type: ToastType, duration: number = 3000) => {
    const id = Math.random().toString(36).substring(2, 9);
    setToasts((prev) => [...prev, { id, message, type, duration }]);

    // Auto-remove toast after duration
    if (duration > 0) {
      setTimeout(() => {
        removeToast(id);
      }, duration);
    }
  }, []);

  const removeToast = useCallback((id: string) => {
    setToasts((prev) => prev.filter((toast) => toast.id !== id));
  }, []);

  const clearToasts = useCallback(() => {
    setToasts([]);
  }, []);

  return (
    <ToastContext.Provider value={{ toasts, addToast, removeToast, clearToasts }}>
      {children}
    </ToastContext.Provider>
  );
}

export function useToast() {
  const context = useContext(ToastContext);
  if (context === undefined) {
    throw new Error('useToast must be used within a ToastProvider');
  }
  return context;
}
```

**frontend/components/ui/Toast.tsx**
```tsx
'use client';

import { useEffect } from 'react';
import { X, CheckCircle, AlertCircle, AlertTriangle, Info } from 'lucide-react';
import { cn } from '@/lib/utils/helpers';
import { Toast as ToastType, useToast } from '@/lib/context/ToastContext';

const toastIcons = {
  success: CheckCircle,
  error: AlertCircle,
  warning: AlertTriangle,
  info: Info,
};

const toastColors = {
  success: 'bg-success-50 border-success-500 text-success-700',
  error: 'bg-danger-50 border-danger-500 text-danger-700',
  warning: 'bg-warning-50 border-warning-500 text-warning-700',
  info: 'bg-blue-50 border-blue-500 text-blue-700',
};

interface ToastProps {
  toast: ToastType;
}

export function Toast({ toast }: ToastProps) {
  const { removeToast } = useToast();
  const Icon = toastIcons[toast.type];

  return (
    <div
      className={cn(
        'pointer-events-auto flex w-full max-w-sm rounded-lg border-l-4 shadow-lg',
        toastColors[toast.type]
      )}
      role="alert"
    >
      <div className="flex flex-1 items-center gap-3 p-4">
        <Icon className="h-5 w-5 flex-shrink-0" />
        <p className="text-sm font-medium">{toast.message}</p>
      </div>
      <button
        onClick={() => removeToast(toast.id)}
        className="p-4 text-secondary-400 hover:text-secondary-600 transition-colors"
      >
        <X className="h-4 w-4" />
      </button>
    </div>
  );
}

export function ToastContainer() {
  const { toasts } = useToast();

  return (
    <div className="fixed bottom-4 right-4 z-50 flex flex-col gap-2">
      {toasts.map((toast) => (
        <Toast key={toast.id} toast={toast} />
      ))}
    </div>
  );
}
```

### Step 2: Create the Confirmation Modal

**frontend/components/ui/Modal.tsx**
```tsx
'use client';

import { Fragment } from 'react';
import { X } from 'lucide-react';
import { Button } from './Button';
import { cn } from '@/lib/utils/helpers';

interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm?: () => void;
  title: string;
  description?: string;
  confirmText?: string;
  cancelText?: string;
  variant?: 'default' | 'danger';
  children?: React.ReactNode;
}

export function Modal({
  isOpen,
  onClose,
  onConfirm,
  title,
  description,
  confirmText = 'Confirm',
  cancelText = 'Cancel',
  variant = 'default',
  children,
}: ModalProps) {
  if (!isOpen) return null;

  const handleBackdropClick = (e: React.MouseEvent<HTMLDivElement>) => {
    if (e.target === e.currentTarget) {
      onClose();
    }
  };

  const handleEscapeKey = (e: React.KeyboardEvent<HTMLDivElement>) => {
    if (e.key === 'Escape') {
      onClose();
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm animate-fade-in"
      onClick={handleBackdropClick}
      onKeyDown={handleEscapeKey}
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
    >
      <div className="w-full max-w-md rounded-lg bg-white p-6 shadow-xl animate-slide-in">
        <div className="flex items-center justify-between">
          <h2 id="modal-title" className="text-xl font-semibold text-secondary-900">
            {title}
          </h2>
          <button
            onClick={onClose}
            className="rounded-md p-1 text-secondary-400 hover:bg-secondary-100 hover:text-secondary-600 transition-colors"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        {description && (
          <p className="mt-2 text-sm text-secondary-600">{description}</p>
        )}

        <div className="mt-4">{children}</div>

        <div className="mt-6 flex justify-end gap-3">
          <Button variant="outline" onClick={onClose}>
            {cancelText}
          </Button>
          {onConfirm && (
            <Button
              variant={variant === 'danger' ? 'destructive' : 'default'}
              onClick={() => {
                onConfirm();
                onClose();
              }}
            >
              {confirmText}
            </Button>
          )}
        </div>
      </div>
    </div>
  );
}
```

### Step 3: Create the Task Form Component

**frontend/app/(dashboard)/tasks/components/TaskForm.tsx**
```tsx
'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { Textarea } from '@/components/ui/Textarea';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { post, put, get } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { Task, Project } from '@/types';
import { TASK_STATUSES, TASK_PRIORITIES } from '@/lib/utils/constants';

interface TaskFormProps {
  task?: Task;
  projectId?: number;
  isEditing?: boolean;
}

export function TaskForm({ task, projectId, isEditing = false }: TaskFormProps) {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [projects, setProjects] = useState<Project[]>([]);
  const [errors, setErrors] = useState<Record<string, string[]>>({});

  const [title, setTitle] = useState(task?.title || '');
  const [description, setDescription] = useState(task?.description || '');
  const [status, setStatus] = useState(task?.status || TASK_STATUSES.TODO);
  const [priority, setPriority] = useState(task?.priority || TASK_PRIORITIES.MEDIUM);
  const [dueDate, setDueDate] = useState(task?.due_date?.split('T')[0] || '');
  const [assignedTo, setAssignedTo] = useState<string>(task?.assigned_to?.toString() || '');
  const [selectedProject, setSelectedProject] = useState<string>(
    projectId?.toString() || task?.project?.toString() || ''
  );

  // Fetch projects for dropdown
  useEffect(() => {
    const fetchProjects = async () => {
      const response = await get<Project[]>(ENDPOINTS.projects.list);
      if (response.data) {
        setProjects(response.data);
      }
    };
    fetchProjects();
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrors({});

    const data = {
      title: title.trim(),
      description: description.trim() || undefined,
      status,
      priority,
      due_date: dueDate || null,
      project: parseInt(selectedProject),
      assigned_to: assignedTo ? parseInt(assignedTo) : null,
    };

    try {
      let response;
      if (isEditing && task) {
        response = await put(ENDPOINTS.tasks.detail(task.id), data);
      } else {
        response = await post(ENDPOINTS.tasks.list, data);
      }

      if (response.error) {
        if (typeof response.error === 'object') {
          setErrors(response.error as Record<string, string[]>);
        } else {
          setErrors({ general: [response.error.detail || 'An error occurred'] });
        }
        return;
      }

      // Success - redirect to task detail or project tasks
      const redirectPath = projectId 
        ? `/projects/${projectId}`
        : `/tasks/${response.data?.id}`;
      router.push(redirectPath);
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
        <CardTitle>{isEditing ? 'Edit Task' : 'Create New Task'}</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* General errors */}
          {errors.general && (
            <div className="rounded-md bg-danger-50 p-3 text-sm text-danger-600">
              {errors.general.join(', ')}
            </div>
          )}

          {/* Title */}
          <div>
            <label htmlFor="title" className="block text-sm font-medium text-secondary-700">
              Task Title *
            </label>
            <Input
              id="title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              required
              className="mt-1"
              placeholder="Enter task title"
            />
            {errors.title && (
              <p className="mt-1 text-sm text-danger-600">{errors.title.join(', ')}</p>
            )}
          </div>

          {/* Description */}
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
              placeholder="Describe the task..."
            />
          </div>

          <div className="grid gap-4 sm:grid-cols-2">
            {/* Status */}
            <div>
              <label htmlFor="status" className="block text-sm font-medium text-secondary-700">
                Status
              </label>
              <select
                id="status"
                value={status}
                onChange={(e) => setStatus(e.target.value)}
                className="mt-1 w-full rounded-md border border-secondary-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value={TASK_STATUSES.TODO}>To Do</option>
                <option value={TASK_STATUSES.IN_PROGRESS}>In Progress</option>
                <option value={TASK_STATUSES.REVIEW}>In Review</option>
                <option value={TASK_STATUSES.DONE}>Done</option>
              </select>
            </div>

            {/* Priority */}
            <div>
              <label htmlFor="priority" className="block text-sm font-medium text-secondary-700">
                Priority
              </label>
              <select
                id="priority"
                value={priority}
                onChange={(e) => setPriority(e.target.value)}
                className="mt-1 w-full rounded-md border border-secondary-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value={TASK_PRIORITIES.LOW}>Low</option>
                <option value={TASK_PRIORITIES.MEDIUM}>Medium</option>
                <option value={TASK_PRIORITIES.HIGH}>High</option>
                <option value={TASK_PRIORITIES.URGENT}>Urgent</option>
              </select>
            </div>
          </div>

          <div className="grid gap-4 sm:grid-cols-2">
            {/* Project */}
            <div>
              <label htmlFor="project" className="block text-sm font-medium text-secondary-700">
                Project *
              </label>
              <select
                id="project"
                value={selectedProject}
                onChange={(e) => setSelectedProject(e.target.value)}
                required
                className="mt-1 w-full rounded-md border border-secondary-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                <option value="">Select a project...</option>
                {projects.map((project) => (
                  <option key={project.id} value={project.id}>
                    {project.name}
                  </option>
                ))}
              </select>
              {errors.project && (
                <p className="mt-1 text-sm text-danger-600">{errors.project.join(', ')}</p>
              )}
            </div>

            {/* Due Date */}
            <div>
              <label htmlFor="dueDate" className="block text-sm font-medium text-secondary-700">
                Due Date
              </label>
              <Input
                id="dueDate"
                type="date"
                value={dueDate}
                onChange={(e) => setDueDate(e.target.value)}
                className="mt-1"
              />
              {errors.due_date && (
                <p className="mt-1 text-sm text-danger-600">{errors.due_date.join(', ')}</p>
              )}
            </div>
          </div>

          {/* Assigned To - For now, just a text input since we don't have user list yet */}
          <div>
            <label htmlFor="assignedTo" className="block text-sm font-medium text-secondary-700">
              Assigned To (User ID)
            </label>
            <Input
              id="assignedTo"
              type="number"
              value={assignedTo}
              onChange={(e) => setAssignedTo(e.target.value)}
              className="mt-1"
              placeholder="Enter user ID"
            />
            {errors.assigned_to && (
              <p className="mt-1 text-sm text-danger-600">{errors.assigned_to.join(', ')}</p>
            )}
          </div>

          {/* Actions */}
          <div className="flex gap-3">
            <Button
              type="submit"
              disabled={loading}
              isLoading={loading}
            >
              {isEditing ? 'Update Task' : 'Create Task'}
            </Button>
            <Button
              type="button"
              variant="outline"
              onClick={() => {
                if (projectId) {
                  router.push(`/projects/${projectId}`);
                } else {
                  router.push('/tasks');
                }
              }}
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

### Step 4: Create Task Status Update Component

**frontend/app/(dashboard)/tasks/[id]/components/TaskStatusUpdate.tsx**
```tsx
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { useToast } from '@/lib/context/ToastContext';
import { patch } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { Task } from '@/types';
import { TASK_STATUS_LABELS, TASK_STATUS_COLORS } from '@/lib/utils/constants';
import { cn } from '@/lib/utils/helpers';

interface TaskStatusUpdateProps {
  task: Task;
}

export function TaskStatusUpdate({ task }: TaskStatusUpdateProps) {
  const router = useRouter();
  const { addToast } = useToast();
  const [status, setStatus] = useState(task.status);
  const [loading, setLoading] = useState(false);

  const statuses = ['todo', 'in_progress', 'review', 'done'];

  const handleStatusChange = async (newStatus: string) => {
    if (newStatus === status) return;

    setLoading(true);
    const response = await patch(ENDPOINTS.tasks.status(task.id), {
      status: newStatus,
    });

    if (response.error) {
      addToast('Failed to update task status', 'error');
      setLoading(false);
      return;
    }

    setStatus(newStatus as Task['status']);
    addToast('Task status updated successfully', 'success');
    router.refresh();
    setLoading(false);
  };

  return (
    <div className="flex flex-wrap items-center gap-2">
      <span className="text-sm font-medium text-secondary-600">Status:</span>
      {statuses.map((s) => (
        <button
          key={s}
          onClick={() => handleStatusChange(s)}
          disabled={loading || s === status}
          className={cn(
            'transition-all',
            s === status && 'cursor-default',
            s !== status && 'hover:scale-105',
            loading && 'opacity-50 cursor-not-allowed'
          )}
        >
          <Badge
            className={cn(
              TASK_STATUS_COLORS[s],
              s === status && 'ring-2 ring-primary-500 ring-offset-2',
              s !== status && 'opacity-60 hover:opacity-100'
            )}
          >
            {TASK_STATUS_LABELS[s]}
          </Badge>
        </button>
      ))}
    </div>
  );
}
```

### Step 5: Create Task Create Pages

**frontend/app/(dashboard)/tasks/create/page.tsx**
```tsx
import { Metadata } from 'next';
import { TaskForm } from '../components/TaskForm';

export const metadata: Metadata = {
  title: 'Create Task',
  description: 'Create a new task',
};

export default function CreateTaskPage() {
  return (
    <div className="container-custom py-6">
      <TaskForm />
    </div>
  );
}
```

**frontend/app/(dashboard)/projects/[id]/tasks/create/page.tsx**
```tsx
import { Metadata } from 'next';
import { TaskForm } from '@/app/(dashboard)/tasks/components/TaskForm';
import { get } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { Project } from '@/types';
import { notFound } from 'next/navigation';

interface CreateProjectTaskPageProps {
  params: {
    id: string;
  };
}

export async function generateMetadata({ params }: CreateProjectTaskPageProps): Promise<Metadata> {
  const project = await getProject(params.id);
  return {
    title: `Create Task in ${project?.name || 'Project'}`,
    description: 'Create a new task in this project',
  };
}

async function getProject(id: string): Promise<Project | null> {
  const response = await get<Project>(ENDPOINTS.projects.detail(parseInt(id)));
  if (response.error) {
    return null;
  }
  return response.data || null;
}

export default async function CreateProjectTaskPage({ params }: CreateProjectTaskPageProps) {
  const project = await getProject(params.id);
  
  if (!project) {
    notFound();
  }

  return (
    <div className="container-custom py-6">
      <h1 className="mb-6 text-2xl font-semibold">
        Create Task in {project.name}
      </h1>
      <TaskForm projectId={project.id} />
    </div>
  );
}
```

### Step 6: Create Task Edit Page

**frontend/app/(dashboard)/tasks/[id]/edit/page.tsx**
```tsx
import { Metadata } from 'next';
import { notFound } from 'next/navigation';
import { TaskForm } from '../../components/TaskForm';
import { get } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { Task } from '@/types';

interface EditTaskPageProps {
  params: {
    id: string;
  };
}

export async function generateMetadata({ params }: EditTaskPageProps): Promise<Metadata> {
  const task = await getTask(params.id);
  return {
    title: `Edit ${task?.title || 'Task'}`,
    description: 'Edit task details',
  };
}

async function getTask(id: string): Promise<Task | null> {
  const response = await get<Task>(ENDPOINTS.tasks.detail(parseInt(id)));
  if (response.error) {
    return null;
  }
  return response.data || null;
}

export default async function EditTaskPage({ params }: EditTaskPageProps) {
  const task = await getTask(params.id);
  
  if (!task) {
    notFound();
  }

  return (
    <div className="container-custom py-6">
      <h1 className="mb-6 text-2xl font-semibold">Edit Task</h1>
      <TaskForm task={task} isEditing />
    </div>
  );
}
```

### Step 7: Create Project Edit Page

**frontend/app/(dashboard)/projects/[id]/edit/page.tsx**
```tsx
import { Metadata } from 'next';
import { notFound } from 'next/navigation';
import { ProjectForm } from '../../components/ProjectForm';
import { get } from '@/lib/api/client';
import { ENDPOINTS } from '@/lib/api/endpoints';
import { Project } from '@/types';

interface EditProjectPageProps {
  params: {
    id: string;
  };
}

export async function generateMetadata({ params }: EditProjectPageProps): Promise<Metadata> {
  const project = await getProject(params.id);
  return {
    title: `Edit ${project?.name || 'Project'}`,
    description: 'Edit project details',
  };
}

async function getProject(id: string): Promise<Project | null> {
  const response = await get<Project>(ENDPOINTS.projects.detail(parseInt(id)));
  if (response.error) {
    return null;
  }
  return response.data || null;
}

export default async function EditProjectPage({ params }: EditProjectPageProps) {
  const project = await getProject(params.id);
  
  if (!project) {
    notFound();
  }

  return (
    <div className="container-custom py-6">
      <h1 className="mb-6 text-2xl font-semibold">Edit Project</h1>
      <ProjectForm project={project} isEditing />
    </div>
  );
}
```

### Step 8: Update Project Detail with Task Status

**frontend/app/(dashboard)/projects/[id]/page.tsx** (update the task list section)

Add this import at the top:
```tsx
import { TASK_STATUS_LABELS, TASK_STATUS_COLORS } from '@/lib/utils/constants';
```

Update the task list section to include status update buttons:
```tsx
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
          <div
            key={task.id}
            className="flex items-center justify-between rounded-lg border border-secondary-200 p-4 hover:bg-secondary-50 transition-colors"
          >
            <Link href={`/tasks/${task.id}`} className="flex-1">
              <div className="flex items-center gap-3">
                <h3 className="font-medium">{task.title}</h3>
                <Badge className={cn(TASK_STATUS_COLORS[task.status])}>
                  {TASK_STATUS_LABELS[task.status]}
                </Badge>
              </div>
            </Link>
            <div className="flex items-center gap-4 text-sm text-secondary-500">
              {task.due_date && (
                <span>Due: {formatDate(task.due_date)}</span>
              )}
              {task.assigned_to_username && (
                <span>Assigned to: {task.assigned_to_username}</span>
              )}
            </div>
          </div>
        ))}
      </div>
    )}
  </CardContent>
</Card>
```

### Step 9: Update Root Layout with Toast Provider

**frontend/app/layout.tsx** (update)
```tsx
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import { ToastProvider } from '@/lib/context/ToastContext';
import { ToastContainer } from '@/components/ui/Toast';
import './globals.css';

const inter = Inter({ 
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter',
});

export const metadata: Metadata = {
  title: {
    default: 'TaskFlow - Task Management Platform',
    template: '%s | TaskFlow',
  },
  description: 'A modern task management platform built with Django and Next.js',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={inter.variable}>
      <body>
        <ToastProvider>
          {children}
          <ToastContainer />
        </ToastProvider>
      </body>
    </html>
  );
}
```

### Step 10: Add Delete with Confirmation in ProjectList

Update the ProjectList component to use the Modal:

**frontend/app/(dashboard)/projects/components/ProjectList.tsx** (update)

Add the Modal import and state:
```tsx
import { Modal } from '@/components/ui/Modal';
import { useToast } from '@/lib/context/ToastContext';

// Add state
const [deleteModalOpen, setDeleteModalOpen] = useState(false);
const [projectToDelete, setProjectToDelete] = useState<Project | null>(null);
const { addToast } = useToast();

// Update handleDelete to open modal
const handleDeleteClick = (project: Project) => {
  setProjectToDelete(project);
  setDeleteModalOpen(true);
};

// Update delete confirmation
const confirmDelete = async () => {
  if (!projectToDelete) return;
  
  const response = await deleteProject(undefined, {
    url: ENDPOINTS.projects.detail(projectToDelete.id),
  } as any);

  if (response.error) {
    addToast('Failed to delete project', 'error');
    return;
  }

  addToast('Project deleted successfully', 'success');
  setProjectToDelete(null);
  setDeleteModalOpen(false);
  refetch();
  router.refresh();
};

// Add Modal at the bottom
<Modal
  isOpen={deleteModalOpen}
  onClose={() => {
    setDeleteModalOpen(false);
    setProjectToDelete(null);
  }}
  onConfirm={confirmDelete}
  title="Delete Project"
  description={`Are you sure you want to delete "${projectToDelete?.name}"? This action cannot be undone and all tasks in this project will also be deleted.`}
  confirmText="Delete Project"
  variant="danger"
/>
```

### Step 11: Update Task Detail with Status Update

**frontend/app/(dashboard)/tasks/[id]/page.tsx** (update)

Add the TaskStatusUpdate import and component:
```tsx
import { TaskStatusUpdate } from './components/TaskStatusUpdate';

// In the header section, add the status update:
<div className="flex flex-wrap items-center gap-3">
  <Badge className={cn(TASK_STATUS_COLORS[task.status])}>
    {TASK_STATUS_LABELS[task.status]}
  </Badge>
  <Badge className={cn(TASK_PRIORITY_COLORS[task.priority])}>
    {TASK_PRIORITY_LABELS[task.priority]}
  </Badge>
  {task.is_overdue && (
    <Badge variant="destructive">Overdue</Badge>
  )}
  <TaskStatusUpdate task={task} />
</div>
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

### Step 2: Complete CRUD Testing

#### Create Operations
1. **Create Project**: 
   - Go to /projects → Click "New Project"
   - Fill in name and description → Submit
   - ✅ Should redirect to projects list with toast notification
   - ✅ New project should appear in list

2. **Create Task**: 
   - Go to /tasks → Click "New Task"
   - Fill in all fields → Submit
   - ✅ Should redirect to task detail with toast notification

3. **Create Task from Project**: 
   - Go to a project detail page → Click "Add Task"
   - Project should be pre-selected
   - ✅ Should create task in that project

#### Read Operations
1. **List Projects**: /projects
   - ✅ Should show all projects with task counts

2. **List Tasks**: /tasks
   - ✅ Should show all tasks with search and filters

3. **Project Detail**: /projects/{id}
   - ✅ Should show project info and tasks

4. **Task Detail**: /tasks/{id}
   - ✅ Should show task info, description, and comments

#### Update Operations
1. **Edit Project**: /projects/{id}/edit
   - ✅ Should update project and show success toast

2. **Edit Task**: /tasks/{id}/edit
   - ✅ Should update task and show success toast

3. **Update Task Status**: Click status badge on task detail
   - ✅ Should update status immediately with optimistic UI

#### Delete Operations
1. **Delete Project**: Click trash icon on project card
   - ✅ Should show confirmation modal
   - ✅ Should delete project and show success toast

2. **Delete Task**: (Add delete button to task detail)
   - ✅ Should show confirmation and delete

### Step 3: Test Error Handling

1. **Create Project with empty name**:
   - ✅ Should show field validation error

2. **Create Task with no project**:
   - ✅ Should show project required error

3. **Delete non-existent project**:
   - ✅ Should show 404 error

4. **Network error simulation**:
   - Stop the backend server
   - Try to create a project
   - ✅ Should show network error toast

### Step 4: Test Toast Notifications

1. **Success**: Create a project
   - ✅ Should show green success toast

2. **Error**: Submit invalid form
   - ✅ Should show error validation messages

3. **Delete**: Delete a project
   - ✅ Should show confirmation modal

---

## Key Takeaways

1. **Complete CRUD operations** across all resources form the foundation of our application.

2. **Toast notifications** provide clear user feedback for all operations.

3. **Confirmation modals** prevent accidental deletions.

4. **Optimistic updates** (in the TaskStatusUpdate) make the app feel faster.

5. **Form validation** happens at both client (basic) and server (comprehensive) levels.

6. **Nested resources** (tasks within projects) require careful URL design.

7. **Server-side data fetching** (in page.tsx) provides fast initial load with revalidation after mutations.

8. **Error handling** at every level ensures a smooth user experience.

---

## Phase 1 Complete!

You've now built the foundation of a complete decoupled application:

✅ REST API with Django REST Framework
✅ Data models with relationships
✅ Serializers with validation
✅ API views with CRUD operations
✅ Next.js 16 frontend with App Router
✅ Server and Client Components
✅ Data fetching and mutations
✅ Complete CRUD operations
✅ Form handling and validation
✅ Toast notifications
✅ Confirmation modals

In **Phase 2**, we'll take this foundation and scale it up with:
- Generic views and ViewSets- Advanced filtering and search
- Pagination
- Better data architecture

---

**End of Part 7**

*Next: Phase 2 - Advanced DRF Architecture & Next.js Data Flow*

---

# Phase 1 Complete Summary

## What You've Built

### Backend (Django + DRF)
- ✅ Custom User model with roles
- ✅ Project, Task, Comment models with relationships
- ✅ ModelSerializers with validation
- ✅ Function-based API views with CRUD operations
- ✅ Proper HTTP methods and status codes
- ✅ Environment-based configuration

### Frontend (Next.js + React)
- ✅ Next.js 16 with App Router
- ✅ Server and Client Components
- ✅ Tailwind CSS styling
- ✅ API client with error handling
- ✅ Complete CRUD operations
- ✅ Form handling with validation
- ✅ Toast notifications
- ✅ Confirmation modals

### Architecture
- ✅ Clean client-server boundary
- ✅ RESTful API design
- ✅ JSON data exchange
- ✅ Environment variables for configuration

## Skills Gained
- REST API design principles
- Django model design and relationships
- DRF serializers and validation
- API view implementation
- Next.js App Router patterns
- React Server and Client Components
- Data fetching patterns
- Form handling in React
- Error handling strategies
- Modern frontend architecture

---

**Ready for Phase 2!**
