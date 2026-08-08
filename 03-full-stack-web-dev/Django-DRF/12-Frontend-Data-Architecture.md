# Part 12: Frontend Data Architecture

## Building Robust Data Management

Welcome to **Part 12** of the Django REST Framework & Next.js 16 masterclass. Now that we have our routing and navigation system in place, it's time to build a comprehensive data architecture. We'll create a robust system for managing data fetching, caching, state management, and synchronization between the client and server.

In this part, we'll:
- Implement server-side data fetching patterns
- Build client-side data fetching with caching
- Implement optimistic updates
- Create a data synchronization layer
- Manage application state effectively
- Build reusable data components

Think of this as building the **nervous system** of your application. It's how data flows between your components, the API, and the user interface, ensuring everything stays in sync.

---

## The Target

We'll build a complete data architecture:

```
frontend/
├── lib/
│   ├── api/
│   │   ├── client.ts          # HTTP client with interceptors
│   │   ├── endpoints.ts       # API endpoint definitions
│   │   └── hooks.ts           # Data fetching hooks
│   ├── cache/
│   │   ├── cache.ts           # Cache management
│   │   └── revalidate.ts      # Revalidation strategies
│   ├── context/
│   │   ├── AppContext.tsx     # Global app context
│   │   └── ToastContext.tsx   # Toast notifications
│   └── store/
│       ├── index.ts           # State management
│       └── slices/            # State slices
├── hooks/
│   ├── useDataSync.ts         # Data synchronization
│   └── useOptimisticUpdate.ts # Optimistic updates
└── components/
    └── providers/
        ├── AppProvider.tsx    # Global providers
        └── QueryProvider.tsx  # React Query provider
```

---

## The Concept

### Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         User Interface                      │
└───────────────────────────────┬─────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                     Client Components                       │
│  (UI state, optimistic updates, user interactions)          │
└───────────────────────────────┬─────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                   Data Layer (Hooks)                        │
│  (useFetch, useMutation, useDataSync)                      │
└───────────────────────────────┬─────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                    Cache Layer                              │
│  (Client-side caching, revalidation)                        │
└───────────────────────────────┬─────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────┐
│                    API Client                               │
│  (HTTP requests, interceptors, error handling)              │
└─────────────────────────────────────────────────────────────┘
```

### Data Fetching Patterns

| Pattern | Where | When | Use Case |
|---------|-------|------|----------|
| **Server Fetching** | Server Components | Initial page load | SEO, initial data |
| **Client Fetching** | Client Components | On user interaction | Search, filters, pagination |
| **Prefetching** | Server/Client | Before navigation | Faster navigation |
| **Background Fetching** | Client Components | On mount | Keeping data fresh |
| **Mutations** | Client Components | On form submit | Create, update, delete |

### Cache Invalidation Strategies

1. **Time-based**: Revalidate after a certain time
2. **On-demand**: Revalidate when data changes
3. **Navigation-based**: Revalidate on route change
4. **Optimistic**: Update UI immediately, revalidate in background

---

## The Implementation

### Step 1: Install Additional Dependencies

```bash
cd frontend
npm install @tanstack/react-query
```

### Step 2: Create React Query Provider

**frontend/components/providers/QueryProvider.tsx** (create)

```tsx
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
            staleTime: 60 * 1000, // 1 minute
            gcTime: 5 * 60 * 1000, // 5 minutes
            retry: 1,
            refetchOnWindowFocus: false,
            refetchOnReconnect: false,
            refetchOnMount: true,
          },
          mutations: {
            retry: 1,
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

### Step 3: Create Data Synchronization Hooks

**frontend/hooks/useDataSync.ts** (create)

```tsx
'use client';

import { useEffect, useCallback, useRef } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { useRouter } from 'next/navigation';

interface SyncOptions {
  keys?: string[][]; // Query keys to invalidate
  url?: string; // URL to revalidate
  refresh?: boolean; // Whether to refresh the page
  delay?: number; // Delay before revalidating
}

export function useDataSync() {
  const queryClient = useQueryClient();
  const router = useRouter();
  const timeoutRef = useRef<NodeJS.Timeout>();

  const syncData = useCallback(
    (options: SyncOptions = {}) => {
      const { keys = [], url, refresh = false, delay = 0 } = options;

      const performSync = () => {
        // Invalidate specific query keys
        if (keys.length > 0) {
          keys.forEach((key) => {
            queryClient.invalidateQueries({ queryKey: key });
          });
        }

        // Invalidate all queries if no keys specified
        if (keys.length === 0 && !url) {
          queryClient.invalidateQueries();
        }

        // Refresh the page
        if (refresh) {
          router.refresh();
        }
      };

      // Clear existing timeout
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }

      // Schedule the sync
      if (delay > 0) {
        timeoutRef.current = setTimeout(performSync, delay);
      } else {
        performSync();
      }
    },
    [queryClient, router]
  );

  // Clean up timeout on unmount
  useEffect(() => {
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, []);

  return { syncData };
}
```

### Step 4: Create Optimistic Update Hook

**frontend/hooks/useOptimisticUpdate.ts** (create)

```tsx
'use client';

import { useState, useCallback } from 'react';

type OptimisticUpdateFn<T, V> = (oldData: T | undefined, variables: V) => T;

interface UseOptimisticUpdateOptions<T> {
  initialData?: T;
  onError?: (error: Error) => void;
  onSuccess?: (data: T) => void;
}

export function useOptimisticUpdate<T, V = any>(
  updateFn: OptimisticUpdateFn<T, V>,
  options: UseOptimisticUpdateOptions<T> = {}
) {
  const { initialData, onError, onSuccess } = options;
  const [data, setData] = useState<T | undefined>(initialData);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const [rollbackData, setRollbackData] = useState<T | undefined>();

  const mutate = useCallback(
    async (variables: V, mutateFn: (vars: V) => Promise<T>) => {
      // Store current data for rollback
      setRollbackData(data);
      setIsLoading(true);
      setError(null);

      // Apply optimistic update
      const optimisticData = updateFn(data, variables);
      setData(optimisticData);

      try {
        // Perform actual mutation
        const result = await mutateFn(variables);
        setData(result);
        onSuccess?.(result);
        return result;
      } catch (err) {
        // Rollback on error
        setData(rollbackData);
        const errorObj = err instanceof Error ? err : new Error('An error occurred');
        setError(errorObj);
        onError?.(errorObj);
        throw errorObj;
      } finally {
        setIsLoading(false);
      }
    },
    [data, rollbackData, updateFn, onError, onSuccess]
  );

  const reset = useCallback(() => {
    setData(initialData);
    setError(null);
    setIsLoading(false);
  }, [initialData]);

  return {
    data,
    isLoading,
    error,
    mutate,
    reset,
  };
}
```

### Step 5: Create Enhanced Data Hooks

**frontend/lib/api/hooks.ts** (update)

```tsx
'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { getPaginated, get, post, put, patch, del } from './client';
import { ENDPOINTS } from './endpoints';
import { useToast } from '@/lib/context/ToastContext';
import { useDataSync } from '@/hooks/useDataSync';

/**
 * Hook for fetching a list with pagination
 */
export function useTasks(params: Record<string, any> = {}) {
  return useQuery({
    queryKey: ['tasks', params],
    queryFn: () => getPaginated(ENDPOINTS.tasks.list, params),
    select: (data) => data.data,
  });
}

/**
 * Hook for fetching a single task
 */
export function useTask(id: number) {
  return useQuery({
    queryKey: ['task', id],
    queryFn: () => get(ENDPOINTS.tasks.detail(id)),
    select: (data) => data.data,
    enabled: !!id,
  });
}

/**
 * Hook for fetching projects with pagination
 */
export function useProjects(params: Record<string, any> = {}) {
  return useQuery({
    queryKey: ['projects', params],
    queryFn: () => getPaginated(ENDPOINTS.projects.list, params),
    select: (data) => data.data,
  });
}

/**
 * Hook for fetching a single project
 */
export function useProject(id: number) {
  return useQuery({
    queryKey: ['project', id],
    queryFn: () => get(ENDPOINTS.projects.detail(id)),
    select: (data) => data.data,
    enabled: !!id,
  });
}

/**
 * Hook for fetching comments for a task
 */
export function useComments(taskId: number, params: Record<string, any> = {}) {
  return useQuery({
    queryKey: ['comments', taskId, params],
    queryFn: () => getPaginated(ENDPOINTS.tasks.comments(taskId), params),
    select: (data) => data.data,
    enabled: !!taskId,
  });
}

/**
 * Mutation hook for creating a task with optimistic updates
 */
export function useCreateTask() {
  const queryClient = useQueryClient();
  const { addToast } = useToast();
  const { syncData } = useDataSync();

  return useMutation({
    mutationFn: (data: any) => post(ENDPOINTS.tasks.list, data),
    onMutate: async (newTask) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries({ queryKey: ['tasks'] });

      // Snapshot the previous value
      const previousTasks = queryClient.getQueryData(['tasks']);

      // Optimistically update to the new value
      queryClient.setQueryData(['tasks'], (old: any) => {
        if (!old) return { results: [newTask] };
        return {
          ...old,
          results: [newTask, ...old.results],
          count: old.count + 1,
        };
      });

      return { previousTasks };
    },
    onError: (err, newTask, context) => {
      // Rollback on error
      if (context?.previousTasks) {
        queryClient.setQueryData(['tasks'], context.previousTasks);
      }
      addToast('Failed to create task', 'error');
    },
    onSuccess: (data) => {
      addToast('Task created successfully', 'success');
      syncData({ keys: [['tasks']] });
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['tasks'] });
    },
  });
}

/**
 * Mutation hook for updating a task
 */
export function useUpdateTask() {
  const queryClient = useQueryClient();
  const { addToast } = useToast();
  const { syncData } = useDataSync();

  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: any }) =>
      put(ENDPOINTS.tasks.detail(id), data),
    onMutate: async ({ id, data }) => {
      await queryClient.cancelQueries({ queryKey: ['task', id] });
      await queryClient.cancelQueries({ queryKey: ['tasks'] });

      const previousTask = queryClient.getQueryData(['task', id]);

      // Optimistically update the task
      queryClient.setQueryData(['task', id], (old: any) => {
        if (!old) return data;
        return { ...old, ...data };
      });

      return { previousTask };
    },
    onError: (err, { id }, context) => {
      if (context?.previousTask) {
        queryClient.setQueryData(['task', id], context.previousTask);
      }
      addToast('Failed to update task', 'error');
    },
    onSuccess: (data, { id }) => {
      addToast('Task updated successfully', 'success');
      syncData({ keys: [['task', id], ['tasks']] });
    },
    onSettled: (data, error, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['task', id] });
      queryClient.invalidateQueries({ queryKey: ['tasks'] });
    },
  });
}

/**
 * Mutation hook for deleting a task
 */
export function useDeleteTask() {
  const queryClient = useQueryClient();
  const { addToast } = useToast();
  const { syncData } = useDataSync();

  return useMutation({
    mutationFn: (id: number) => del(ENDPOINTS.tasks.detail(id)),
    onMutate: async (id) => {
      await queryClient.cancelQueries({ queryKey: ['tasks'] });

      const previousTasks = queryClient.getQueryData(['tasks']);

      // Optimistically remove the task
      queryClient.setQueryData(['tasks'], (old: any) => {
        if (!old) return old;
        return {
          ...old,
          results: old.results.filter((task: any) => task.id !== id),
          count: old.count - 1,
        };
      });

      return { previousTasks };
    },
    onError: (err, id, context) => {
      if (context?.previousTasks) {
        queryClient.setQueryData(['tasks'], context.previousTasks);
      }
      addToast('Failed to delete task', 'error');
    },
    onSuccess: () => {
      addToast('Task deleted successfully', 'success');
      syncData({ keys: [['tasks']] });
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['tasks'] });
    },
  });
}

/**
 * Mutation hook for updating task status
 */
export function useUpdateTaskStatus() {
  const queryClient = useQueryClient();
  const { addToast } = useToast();
  const { syncData } = useDataSync();

  return useMutation({
    mutationFn: ({ id, status }: { id: number; status: string }) =>
      patch(ENDPOINTS.tasks.status(id), { status }),
    onMutate: async ({ id, status }) => {
      await queryClient.cancelQueries({ queryKey: ['task', id] });
      await queryClient.cancelQueries({ queryKey: ['tasks'] });

      const previousTask = queryClient.getQueryData(['task', id]);

      // Optimistically update the task status
      queryClient.setQueryData(['task', id], (old: any) => {
        if (!old) return { status };
        return { ...old, status };
      });

      return { previousTask };
    },
    onError: (err, { id }, context) => {
      if (context?.previousTask) {
        queryClient.setQueryData(['task', id], context.previousTask);
      }
      addToast('Failed to update status', 'error');
    },
    onSuccess: (data, { id, status }) => {
      addToast('Status updated successfully', 'success');
      syncData({ keys: [['task', id], ['tasks']] });
    },
    onSettled: (data, error, { id }) => {
      queryClient.invalidateQueries({ queryKey: ['task', id] });
      queryClient.invalidateQueries({ queryKey: ['tasks'] });
    },
  });
}

/**
 * Hook for creating a comment with optimistic updates
 */
export function useCreateComment() {
  const queryClient = useQueryClient();
  const { addToast } = useToast();
  const { syncData } = useDataSync();

  return useMutation({
    mutationFn: (data: any) => post(ENDPOINTS.comments.list, data),
    onMutate: async (newComment) => {
      const taskId = newComment.task;
      await queryClient.cancelQueries({ queryKey: ['comments', taskId] });

      const previousComments = queryClient.getQueryData(['comments', taskId]);

      // Optimistically add the comment
      queryClient.setQueryData(['comments', taskId], (old: any) => {
        if (!old) return { results: [newComment] };
        return {
          ...old,
          results: [...old.results, newComment],
          count: old.count + 1,
        };
      });

      return { previousComments };
    },
    onError: (err, newComment, context) => {
      if (context?.previousComments) {
        queryClient.setQueryData(
          ['comments', newComment.task],
          context.previousComments
        );
      }
      addToast('Failed to add comment', 'error');
    },
    onSuccess: (data, variables) => {
      addToast('Comment added successfully', 'success');
      syncData({ keys: [['comments', variables.task]] });
    },
    onSettled: (data, error, variables) => {
      queryClient.invalidateQueries({ queryKey: ['comments', variables.task] });
    },
  });
}
```

### Step 6: Update Components to Use New Hooks

**frontend/app/(dashboard)/tasks/components/TaskList.tsx** (update with React Query)

```tsx
'use client';

import { useState, useMemo } from 'react';
import Link from 'next/link';
import { Plus, Search, X } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card, CardContent } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { Input } from '@/components/ui/Input';
import { LoadingSpinner } from '@/components/ui/LoadingSpinner';
import { Pagination } from '@/components/ui/Pagination';
import { PageSizeSelector } from '@/components/ui/PageSizeSelector';
import { useTasks } from '@/lib/api/hooks';
import { TASK_STATUS_LABELS, TASK_STATUS_COLORS, TASK_PRIORITY_LABELS, TASK_PRIORITY_COLORS } from '@/lib/utils/constants';
import { formatDate, cn } from '@/lib/utils/helpers';

interface TaskListProps {
  projectId?: number;
}

export function TaskList({ projectId }: TaskListProps) {
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('');
  const [page, setPage] = useState(1);
  const [pageSize, setPageSize] = useState(20);

  // Build query params
  const queryParams = {
    page,
    page_size: pageSize,
    ...(statusFilter && { status: statusFilter }),
    ...(searchTerm && { search: searchTerm }),
    ...(projectId && { project: projectId }),
  };

  const { data, isLoading, error } = useTasks(queryParams);
  const tasks = data?.results || [];
  const totalTasks = data?.count || 0;
  const totalPages = data?.total_pages || 1;

  // Get unique statuses for filter
  const statuses = useMemo(() => {
    if (!tasks) return [];
    return [...new Set(tasks.map((t: any) => t.status))];
  }, [tasks]);

  // Debounced search
  const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setSearchTerm(value);
    setPage(1); // Reset to first page on search
  };

  if (isLoading) {
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
          Error loading tasks: {(error as Error).message}
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h2 className="text-2xl font-semibold">Tasks</h2>
          <p className="text-sm text-secondary-500">
            {totalTasks} task{totalTasks !== 1 ? 's' : ''} found
          </p>
        </div>
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
            onChange={handleSearchChange}
            className="pl-9"
          />
          {searchTerm && (
            <button
              onClick={() => {
                setSearchTerm('');
                setPage(1);
              }}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-secondary-400 hover:text-secondary-600"
            >
              <X className="h-4 w-4" />
            </button>
          )}
        </div>
        <select
          value={statusFilter}
          onChange={(e) => {
            setStatusFilter(e.target.value);
            setPage(1);
          }}
          className="rounded-md border border-secondary-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
        >
          <option value="">All Statuses</option>
          {statuses.map(status => (
            <option key={status} value={status}>
              {TASK_STATUS_LABELS[status as keyof typeof TASK_STATUS_LABELS]}
            </option>
          ))}
        </select>
        <PageSizeSelector
          value={pageSize}
          onChange={(size) => {
            setPageSize(size);
            setPage(1);
          }}
        />
        {statusFilter && (
          <Button
            variant="ghost"
            size="sm"
            onClick={() => {
              setStatusFilter('');
              setPage(1);
            }}
          >
            Clear Filter
          </Button>
        )}
      </div>

      {/* Task List */}
      {tasks.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center">
            <p className="text-secondary-500">
              No tasks found matching your criteria
            </p>
          </CardContent>
        </Card>
      ) : (
        <>
          <div className="space-y-2">
            {tasks.map((task: any) => (
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

          {/* Pagination */}
          {totalPages > 1 && (
            <div className="flex items-center justify-between pt-4">
              <Pagination
                currentPage={page}
                totalPages={totalPages}
                onPageChange={setPage}
              />
              <span className="text-sm text-secondary-500">
                Showing {((page - 1) * pageSize) + 1} -{' '}
                {Math.min(page * pageSize, totalTasks)} of {totalTasks}
              </span>
            </div>
          )}
        </>
      )}
    </div>
  );
}
```

### Step 7: Update Root Layout with Query Provider

**frontend/app/layout.tsx** (update)

```tsx
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import { ToastProvider } from '@/lib/context/ToastContext';
import { QueryProvider } from '@/components/providers/QueryProvider';
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
        <QueryProvider>
          <ToastProvider>
            {children}
            <ToastContainer />
          </ToastProvider>
        </QueryProvider>
      </body>
    </html>
  );
}
```

---

## The Verification

### Step 1: Start the Servers

```bash
# Terminal 1 - Backend
cd backend
source venv/bin/activate
python manage.py runserver

# Terminal 2 - Frontend
cd frontend
npm run dev
```

### Step 2: Test Data Fetching

1. Open http://localhost:3000/tasks
2. Open React Query DevTools (bottom right corner)
3. You should see queries for tasks
4. Check network tab for API calls

### Step 3: Test Optimistic Updates

1. Go to Tasks page
2. Click "New Task"
3. Fill in the form and submit
4. Notice the optimistic update in the UI
5. The task should appear immediately, then revalidate

### Step 4: Test Cache Invalidation

1. Go to Tasks page
2. Note the current tasks
3. Edit a task
4. Submit changes
5. The data should update immediately (optimistic)
6. The cache should be invalidated and refetched

### Step 5: Test Error Handling

1. Stop the backend server
2. Try to create a task
3. You should see an error toast
4. The optimistic update should rollback

---

## Key Takeaways

1. **React Query** provides powerful data fetching and caching capabilities.

2. **Optimistic updates** improve user experience by making interactions feel instant.

3. **Cache invalidation** ensures data consistency across the application.

4. **Revalidation strategies** (time-based, on-demand) keep data fresh.

5. **Error handling** is crucial for a good user experience - always handle errors gracefully.

6. **Data synchronization** between server and client is essential for data consistency.

7. **Query keys** are the foundation of React Query's caching system.

8. **Mutations** with optimistic updates provide the best user experience.

---

## What's Next

In **Part 13**, we'll build searchable data interfaces. You'll learn:

- Building advanced search interfaces
- Combining filters, search, and pagination
- URL-based state management
- Debouncing search inputs
- Building data tables

---

**End of Part 12**

*Next: Part 13 - Searchable Data Interfaces*
