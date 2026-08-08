# Part 13: Searchable Data Interfaces

## Building Advanced Data Tables and Search

Welcome to **Part 13** of the Django REST Framework & Next.js 16 masterclass. This is the final part of Phase 2, where we'll build sophisticated searchable data interfaces that combine all the features we've learned: searching, filtering, sorting, and pagination, all synchronized with the URL.

In this part, we'll:
- Build a comprehensive data table component
- Implement URL-based state management
- Create debounced search inputs
- Combine filters, sorting, and pagination
- Build advanced filter panels
- Create reusable data table components

Think of this as building the **control center** for your data. Users can search, filter, sort, and navigate through large datasets with ease, and everything is reflected in the URL so they can share and bookmark their views.

---

## The Target

We'll build a complete searchable data interface:

```
frontend/
├── components/
│   └── data/
│       ├── DataTable.tsx           # Reusable data table
│       ├── DataTableHeader.tsx     # Sortable headers
│       ├── DataTableRow.tsx        # Data row component
│       ├── DataTablePagination.tsx # Pagination controls
│       ├── SearchBar.tsx           # Debounced search input
│       ├── FilterPanel.tsx         # Advanced filters
│       └── DataTableToolbar.tsx    # Toolbar with controls
├── hooks/
│   └── useUrlState.ts             # URL state management
└── app/(dashboard)/
    └── tasks/
        └── page.tsx               # Enhanced tasks page with data table
```

---

## The Concept

### URL State Management

URL state is a powerful pattern for data interfaces:

1. **Shareable**: Users can share links with specific filters applied
2. **Bookmarkable**: Users can bookmark filtered views
3. **Browser navigation**: Back/forward buttons work naturally
4. **Server-side rendering**: State is available on the server

**URL Example**:
```
/tasks?search=api&status=in_progress&priority=high&page=2&sort=-created_at
```

### Debouncing

Debouncing prevents excessive API calls while typing:

```
User types: "a" → "ap" → "api"
Without debouncing: 3 API calls
With debouncing: 1 API call (after typing stops)
```

### Data Table Architecture

```
┌─────────────────────────────────────────────────────┐
│  DataTableToolbar                                   │
│  ┌──────────────┐ ┌──────────┐ ┌───────────────┐   │
│  │ Search Bar   │ │ Filters  │ │ Page Size     │   │
│  └──────────────┘ └──────────┘ └───────────────┘   │
├─────────────────────────────────────────────────────┤
│  DataTableHeader (sortable)                         │
│  ┌──────┬──────────┬────────┬────────┬────────┐    │
│  │ ID ▼ │ Title ▲ │ Status │ Priority│ Due    │    │
│  ├──────┼──────────┼────────┼────────┼────────┤    │
│  │ 1    │ Task 1   │ Doing  │ High   │ 2026-01 │    │
│  │ 2    │ Task 2   │ Done   │ Low    │ 2026-02 │    │
│  │ 3    │ Task 3   │ Todo   │ Medium │ 2026-03 │    │
│  └──────┴──────────┴────────┴────────┴────────┘    │
├─────────────────────────────────────────────────────┤
│  DataTablePagination                                │
│  ◄ 1 2 3 4 5 ►  Showing 1-20 of 100                │
└─────────────────────────────────────────────────────┘
```

---

## The Implementation

### Step 1: Create URL State Hook

**frontend/hooks/useUrlState.ts** (create)

```tsx
'use client';

import { useRouter, useSearchParams } from 'next/navigation';
import { useCallback, useMemo } from 'react';

export function useUrlState<T = Record<string, any>>() {
  const router = useRouter();
  const searchParams = useSearchParams();

  const state = useMemo(() => {
    const params: Record<string, any> = {};
    searchParams.forEach((value, key) => {
      // Parse numeric values
      if (value && !isNaN(Number(value)) && value !== '') {
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

  const setState = useCallback(
    (newState: Partial<T>, options?: { replace?: boolean }) => {
      const params = new URLSearchParams(searchParams.toString());
      
      Object.entries(newState).forEach(([key, value]) => {
        if (value === undefined || value === null || value === '') {
          params.delete(key);
        } else {
          params.set(key, String(value));
        }
      });

      const url = `${window.location.pathname}?${params.toString()}`;
      
      if (options?.replace) {
        router.replace(url);
      } else {
        router.push(url);
      }
    },
    [router, searchParams]
  );

  const updateState = useCallback(
    (updates: Partial<T>) => {
      setState({ ...state, ...updates });
    },
    [state, setState]
  );

  const clearState = useCallback(() => {
    const params = new URLSearchParams();
    const url = `${window.location.pathname}${params.toString() ? `?${params.toString()}` : ''}`;
    router.push(url);
  }, [router]);

  const getState = useCallback(
    <K extends keyof T>(key: K): T[K] => {
      return state[key];
    },
    [state]
  );

  return {
    state,
    setState,
    updateState,
    clearState,
    getState,
    hasState: Object.keys(state).length > 0,
  };
}
```

### Step 2: Create SearchBar Component

**frontend/components/data/SearchBar.tsx** (create)

```tsx
'use client';

import { useState, useEffect, useCallback } from 'react';
import { Search, X } from 'lucide-react';
import { Input } from '@/components/ui/Input';

interface SearchBarProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  debounceDelay?: number;
  className?: string;
}

export function SearchBar({
  value,
  onChange,
  placeholder = 'Search...',
  debounceDelay = 300,
  className,
}: SearchBarProps) {
  const [internalValue, setInternalValue] = useState(value);

  // Debounce the onChange callback
  useEffect(() => {
    const timer = setTimeout(() => {
      if (internalValue !== value) {
        onChange(internalValue);
      }
    }, debounceDelay);

    return () => clearTimeout(timer);
  }, [internalValue, onChange, debounceDelay, value]);

  // Update internal value when prop changes
  useEffect(() => {
    if (value !== internalValue) {
      setInternalValue(value);
    }
  }, [value]);

  const handleClear = useCallback(() => {
    setInternalValue('');
    onChange('');
  }, [onChange]);

  return (
    <div className={`relative flex-1 ${className}`}>
      <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-secondary-400" />
      <Input
        type="text"
        value={internalValue}
        onChange={(e) => setInternalValue(e.target.value)}
        placeholder={placeholder}
        className="pl-9 pr-9"
      />
      {internalValue && (
        <button
          onClick={handleClear}
          className="absolute right-3 top-1/2 -translate-y-1/2 text-secondary-400 hover:text-secondary-600"
          aria-label="Clear search"
        >
          <X className="h-4 w-4" />
        </button>
      )}
    </div>
  );
}
```

### Step 3: Create DataTable Components

**frontend/components/data/DataTable.tsx** (create)

```tsx
'use client';

import { ReactNode } from 'react';
import { Card, CardContent } from '@/components/ui/Card';
import { LoadingSpinner } from '@/components/ui/LoadingSpinner';

export interface Column<T> {
  key: string;
  header: string;
  accessor?: (item: T) => ReactNode;
  sortable?: boolean;
  className?: string;
  headerClassName?: string;
}

interface DataTableProps<T> {
  data: T[];
  columns: Column<T>[];
  loading?: boolean;
  error?: Error | null;
  emptyMessage?: string;
  onSort?: (key: string, direction: 'asc' | 'desc') => void;
  sortKey?: string;
  sortDirection?: 'asc' | 'desc';
  className?: string;
  rowClassName?: string | ((item: T, index: number) => string);
}

export function DataTable<T extends { id: string | number }>({
  data,
  columns,
  loading = false,
  error = null,
  emptyMessage = 'No data found',
  onSort,
  sortKey,
  sortDirection,
  className,
  rowClassName,
}: DataTableProps<T>) {
  if (loading) {
    return (
      <Card>
        <CardContent className="flex justify-center py-12">
          <LoadingSpinner size="lg" />
        </CardContent>
      </Card>
    );
  }

  if (error) {
    return (
      <Card>
        <CardContent className="py-12 text-center text-danger-600">
          Error: {error.message}
        </CardContent>
      </Card>
    );
  }

  if (data.length === 0) {
    return (
      <Card>
        <CardContent className="py-12 text-center text-secondary-500">
          {emptyMessage}
        </CardContent>
      </Card>
    );
  }

  const handleSort = (key: string) => {
    if (!onSort || !columns.find(c => c.key === key)?.sortable) return;
    
    const newDirection = sortKey === key && sortDirection === 'asc' ? 'desc' : 'asc';
    onSort(key, newDirection);
  };

  return (
    <Card className={className}>
      <CardContent className="p-0 overflow-x-auto">
        <table className="w-full">
          <thead>
            <tr className="border-b border-secondary-200 bg-secondary-50">
              {columns.map((column) => {
                const isSorted = sortKey === column.key;
                const isSortable = column.sortable && onSort;
                const sortIcon = isSorted 
                  ? sortDirection === 'asc' ? '↑' : '↓'
                  : '↕';

                return (
                  <th
                    key={column.key}
                    onClick={() => isSortable && handleSort(column.key)}
                    className={`
                      px-4 py-3 text-left text-xs font-medium text-secondary-600 uppercase tracking-wider
                      ${isSortable ? 'cursor-pointer hover:bg-secondary-100 transition-colors' : ''}
                      ${column.headerClassName || ''}
                    `}
                  >
                    <div className="flex items-center gap-1">
                      {column.header}
                      {isSortable && (
                        <span className="text-secondary-400 text-xs">
                          {sortIcon}
                        </span>
                      )}
                    </div>
                  </th>
                );
              })}
            </tr>
          </thead>
          <tbody>
            {data.map((item, index) => {
              const rowClass = typeof rowClassName === 'function'
                ? rowClassName(item, index)
                : rowClassName || '';

              return (
                <tr
                  key={item.id}
                  className={`
                    border-b border-secondary-100 hover:bg-secondary-50 transition-colors
                    ${rowClass}
                  `}
                >
                  {columns.map((column) => (
                    <td
                      key={`${item.id}-${column.key}`}
                      className={`px-4 py-3 text-sm ${column.className || ''}`}
                    >
                      {column.accessor ? column.accessor(item) : (item as any)[column.key]}
                    </td>
                  ))}
                </tr>
              );
            })}
          </tbody>
        </table>
      </CardContent>
    </Card>
  );
}
```

**frontend/components/data/DataTableToolbar.tsx** (create)

```tsx
'use client';

import { ReactNode } from 'react';

interface DataTableToolbarProps {
  search?: {
    value: string;
    onChange: (value: string) => void;
    placeholder?: string;
  };
  filters?: ReactNode;
  actions?: ReactNode;
  className?: string;
}

export function DataTableToolbar({
  search,
  filters,
  actions,
  className,
}: DataTableToolbarProps) {
  return (
    <div className={`flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between ${className}`}>
      <div className="flex flex-1 items-center gap-3">
        {search && <SearchBar {...search} />}
        {filters}
      </div>
      {actions && <div className="flex items-center gap-2">{actions}</div>}
    </div>
  );
}
```

### Step 4: Create Enhanced Tasks Page

**frontend/app/(dashboard)/tasks/page.tsx** (update)

```tsx
'use client';

import { useMemo } from 'react';
import Link from 'next/link';
import { Plus } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { Pagination } from '@/components/ui/Pagination';
import { PageSizeSelector } from '@/components/ui/PageSizeSelector';
import { DataTable, Column } from '@/components/data/DataTable';
import { DataTableToolbar } from '@/components/data/DataTableToolbar';
import { SearchBar } from '@/components/data/SearchBar';
import { useTasks } from '@/lib/api/hooks';
import { useUrlState } from '@/hooks/useUrlState';
import { TASK_STATUS_LABELS, TASK_STATUS_COLORS, TASK_PRIORITY_LABELS, TASK_PRIORITY_COLORS } from '@/lib/utils/constants';
import { cn, formatDate } from '@/lib/utils/helpers';

interface UrlState {
  search?: string;
  status?: string;
  priority?: string;
  page?: number;
  page_size?: number;
  sort?: string;
}

export default function TasksPage() {
  // URL state
  const { state, updateState } = useUrlState<UrlState>();
  const search = state.search || '';
  const status = state.status || '';
  const priority = state.priority || '';
  const page = state.page || 1;
  const pageSize = state.page_size || 20;
  const sort = state.sort || '-created_at';

  // Build query params
  const queryParams = {
    page,
    page_size: pageSize,
    ...(search && { search }),
    ...(status && { status }),
    ...(priority && { priority }),
    ...(sort && { ordering: sort }),
  };

  // Fetch data
  const { data, isLoading, error } = useTasks(queryParams);
  const tasks = data?.results || [];
  const totalTasks = data?.count || 0;
  const totalPages = data?.total_pages || 1;

  // Handle sort
  const handleSort = (key: string, direction: 'asc' | 'desc') => {
    const sortKey = direction === 'asc' ? key : `-${key}`;
    updateState({ sort: sortKey, page: 1 });
  };

  // Columns definition
  const columns: Column<any>[] = useMemo(() => [
    {
      key: 'title',
      header: 'Title',
      sortable: true,
      accessor: (task) => (
        <Link href={`/tasks/${task.id}`} className="hover:text-primary-600">
          {task.title}
        </Link>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      sortable: true,
      accessor: (task) => (
        <Badge className={cn(TASK_STATUS_COLORS[task.status])}>
          {TASK_STATUS_LABELS[task.status]}
        </Badge>
      ),
    },
    {
      key: 'priority',
      header: 'Priority',
      sortable: true,
      accessor: (task) => (
        <Badge className={cn(TASK_PRIORITY_COLORS[task.priority])}>
          {TASK_PRIORITY_LABELS[task.priority]}
        </Badge>
      ),
    },
    {
      key: 'project_name',
      header: 'Project',
      sortable: false,
      accessor: (task) => (
        <Link href={`/projects/${task.project}`} className="text-primary-600 hover:underline">
          {task.project_name}
        </Link>
      ),
    },
    {
      key: 'assigned_to_username',
      header: 'Assigned To',
      sortable: false,
      accessor: (task) => task.assigned_to_username || 'Unassigned',
    },
    {
      key: 'due_date',
      header: 'Due Date',
      sortable: true,
      accessor: (task) => task.due_date ? formatDate(task.due_date) : 'No date',
    },
    {
      key: 'created_at',
      header: 'Created',
      sortable: true,
      accessor: (task) => formatDate(task.created_at),
    },
  ], []);

  // Extract sort key and direction
  const sortKey = sort.startsWith('-') ? sort.slice(1) : sort;
  const sortDirection = sort.startsWith('-') ? 'desc' : 'asc';

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Tasks</h1>
        <Link href="/tasks/create">
          <Button>
            <Plus className="mr-2 h-4 w-4" />
            New Task
          </Button>
        </Link>
      </div>

      <DataTableToolbar
        search={{
          value: search,
          onChange: (value) => updateState({ search: value, page: 1 }),
          placeholder: 'Search tasks...',
        }}
        filters={
          <>
            <select
              value={status}
              onChange={(e) => updateState({ status: e.target.value, page: 1 })}
              className="rounded-md border border-secondary-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="">All Statuses</option>
              {Object.entries(TASK_STATUS_LABELS).map(([value, label]) => (
                <option key={value} value={value}>
                  {label}
                </option>
              ))}
            </select>
            <select
              value={priority}
              onChange={(e) => updateState({ priority: e.target.value, page: 1 })}
              className="rounded-md border border-secondary-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="">All Priorities</option>
              {Object.entries(TASK_PRIORITY_LABELS).map(([value, label]) => (
                <option key={value} value={value}>
                  {label}
                </option>
              ))}
            </select>
          </>
        }
        actions={
          <PageSizeSelector
            value={pageSize}
            onChange={(size) => updateState({ page_size: size, page: 1 })}
          />
        }
      />

      <DataTable
        data={tasks}
        columns={columns}
        loading={isLoading}
        error={error as Error | null}
        emptyMessage="No tasks found matching your criteria"
        onSort={handleSort}
        sortKey={sortKey}
        sortDirection={sortDirection}
      />

      {totalPages > 1 && (
        <div className="flex items-center justify-between">
          <Pagination
            currentPage={page}
            totalPages={totalPages}
            onPageChange={(page) => updateState({ page })}
          />
          <span className="text-sm text-secondary-500">
            Showing {((page - 1) * pageSize) + 1} -{' '}
            {Math.min(page * pageSize, totalTasks)} of {totalTasks}
          </span>
        </div>
      )}
    </div>
  );
}
```

### Step 5: Create Enhanced Projects Page

**frontend/app/(dashboard)/projects/page.tsx** (update)

```tsx
'use client';

import { useMemo } from 'react';
import Link from 'next/link';
import { Plus } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { DataTable, Column } from '@/components/data/DataTable';
import { DataTableToolbar } from '@/components/data/DataTableToolbar';
import { SearchBar } from '@/components/data/SearchBar';
import { useProjects } from '@/lib/api/hooks';
import { useUrlState } from '@/hooks/useUrlState';
import { formatDate } from '@/lib/utils/helpers';

interface UrlState {
  search?: string;
  page?: number;
  page_size?: number;
  sort?: string;
}

export default function ProjectsPage() {
  const { state, updateState } = useUrlState<UrlState>();
  const search = state.search || '';
  const page = state.page || 1;
  const pageSize = state.page_size || 20;
  const sort = state.sort || '-created_at';

  const queryParams = {
    page,
    page_size: pageSize,
    ...(search && { search }),
    ...(sort && { ordering: sort }),
  };

  const { data, isLoading, error } = useProjects(queryParams);
  const projects = data?.results || [];
  const totalProjects = data?.count || 0;
  const totalPages = data?.total_pages || 1;

  const handleSort = (key: string, direction: 'asc' | 'desc') => {
    const sortKey = direction === 'asc' ? key : `-${key}`;
    updateState({ sort: sortKey, page: 1 });
  };

  const columns: Column<any>[] = useMemo(() => [
    {
      key: 'name',
      header: 'Name',
      sortable: true,
      accessor: (project) => (
        <Link href={`/projects/${project.id}`} className="hover:text-primary-600">
          {project.name}
        </Link>
      ),
    },
    {
      key: 'description',
      header: 'Description',
      sortable: false,
      accessor: (project) => project.description || 'No description',
    },
    {
      key: 'task_count',
      header: 'Tasks',
      sortable: true,
      accessor: (project) => (
        <Badge variant="secondary">
          {project.task_count} tasks
        </Badge>
      ),
    },
    {
      key: 'completed_task_count',
      header: 'Completed',
      sortable: true,
      accessor: (project) => (
        <Badge variant="success">
          {project.completed_task_count} done
        </Badge>
      ),
    },
    {
      key: 'created_by_username',
      header: 'Created By',
      sortable: false,
      accessor: (project) => project.created_by_username,
    },
    {
      key: 'created_at',
      header: 'Created',
      sortable: true,
      accessor: (project) => formatDate(project.created_at),
    },
  ], []);

  const sortKey = sort.startsWith('-') ? sort.slice(1) : sort;
  const sortDirection = sort.startsWith('-') ? 'desc' : 'asc';

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Projects</h1>
        <Link href="/projects/create">
          <Button>
            <Plus className="mr-2 h-4 w-4" />
            New Project
          </Button>
        </Link>
      </div>

      <DataTableToolbar
        search={{
          value: search,
          onChange: (value) => updateState({ search: value, page: 1 }),
          placeholder: 'Search projects...',
        }}
      />

      <DataTable
        data={projects}
        columns={columns}
        loading={isLoading}
        error={error as Error | null}
        emptyMessage="No projects found"
        onSort={handleSort}
        sortKey={sortKey}
        sortDirection={sortDirection}
      />

      {totalPages > 1 && (
        <div className="flex items-center justify-between">
          <Pagination
            currentPage={page}
            totalPages={totalPages}
            onPageChange={(page) => updateState({ page })}
          />
          <span className="text-sm text-secondary-500">
            Showing {((page - 1) * pageSize) + 1} -{' '}
            {Math.min(page * pageSize, totalProjects)} of {totalProjects}
          </span>
        </div>
      )}
    </div>
  );
}
```

### Step 6: Update Task Detail with Status Quick Actions

**frontend/app/(dashboard)/tasks/[id]/page.tsx** (update with status update)

```tsx
'use client';

import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { ArrowLeft, Pencil } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Badge } from '@/components/ui/Badge';
import { LoadingSpinner } from '@/components/ui/LoadingSpinner';
import { useTask, useUpdateTaskStatus } from '@/lib/api/hooks';
import { useToast } from '@/lib/context/ToastContext';
import { TASK_STATUS_LABELS, TASK_STATUS_COLORS, TASK_PRIORITY_LABELS, TASK_PRIORITY_COLORS } from '@/lib/utils/constants';
import { formatDateTime, cn } from '@/lib/utils/helpers';
import { CommentList } from './components/CommentList';

interface TaskPageProps {
  params: {
    id: string;
  };
}

export default function TaskPage({ params }: TaskPageProps) {
  const router = useRouter();
  const { addToast } = useToast();
  const taskId = parseInt(params.id);

  const { data: task, isLoading, error } = useTask(taskId);
  const { mutate: updateStatus, isPending: isUpdatingStatus } = useUpdateTaskStatus();

  if (isLoading) {
    return (
      <div className="flex h-[calc(100vh-6rem)] items-center justify-center">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (error || !task) {
    return (
      <div className="flex h-[calc(100vh-6rem)] items-center justify-center">
        <Card className="max-w-md">
          <CardContent className="py-12 text-center">
            <p className="text-danger-600">Failed to load task</p>
            <Button className="mt-4" onClick={() => router.back()}>
              Go Back
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  const handleStatusChange = (newStatus: string) => {
    updateStatus({ id: task.id, status: newStatus });
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-start justify-between">
        <div>
          <Link
            href="/tasks"
            className="inline-flex items-center gap-1 text-sm text-secondary-500 hover:text-secondary-700"
          >
            <ArrowLeft className="h-4 w-4" />
            Back to Tasks
          </Link>
          <h1 className="mt-2 text-3xl font-bold">{task.title}</h1>
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
        <div className="flex gap-2">
          <Link href={`/tasks/${task.id}/edit`}>
            <Button variant="outline">
              <Pencil className="mr-2 h-4 w-4" />
              Edit
            </Button>
          </Link>
        </div>
      </div>

      {/* Quick Status Update */}
      <Card>
        <CardHeader>
          <CardTitle>Quick Status Update</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex flex-wrap gap-2">
            {Object.entries(TASK_STATUS_LABELS).map(([status, label]) => (
              <Button
                key={status}
                variant={task.status === status ? 'default' : 'outline'}
                size="sm"
                onClick={() => handleStatusChange(status)}
                disabled={isUpdatingStatus || task.status === status}
              >
                {label}
              </Button>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Details Grid */}
      <div className="grid gap-6 lg:grid-cols-3">
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
              <CardTitle>Comments ({task.comment_count})</CardTitle>
            </CardHeader>
            <CardContent>
              <CommentList taskId={task.id} />
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
                <Link
                  href={`/projects/${task.project}`}
                  className="font-medium hover:text-primary-600"
                >
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

### Step 2: Test URL State Management

1. Go to http://localhost:3000/tasks
2. Apply a search: "api"
3. Check the URL: should be `/tasks?search=api`
4. Apply a status filter
5. URL should update: `/tasks?search=api&status=in_progress`
6. Refresh the page - filters should persist
7. Copy the URL and open in a new tab - filters should apply

### Step 3: Test Search Debouncing

1. Go to Tasks page
2. Open network tab in dev tools
3. Type "a" in search
4. Wait 300ms - should see one API request
5. Type "p" quickly after
6. Should see only one API request after typing stops

### Step 4: Test Sorting

1. Click a column header (e.g., "Title")
2. URL should update with sort parameter
3. Click again to reverse sort
4. Data should reorder accordingly

### Step 5: Test Combined Functionality

1. Search for "api"
2. Filter by status "in_progress"
3. Sort by priority
4. Navigate to page 2
5. URL should reflect all states
6. All filters should work together

### Step 6: Test Quick Status Update

1. Go to a task detail
2. Click a status button
3. Should update optimistically
4. Should show success toast
5. The UI should reflect the new status

---

## Key Takeaways

1. **URL state management** provides shareable, bookmarkable views.

2. **Debouncing** reduces API calls and improves performance.

3. **Data tables** provide a consistent way to display and interact with data.

4. **Sorting** is essential for data exploration.

5. **Combined filters** (search, status, priority) provide powerful data discovery.

6. **Optimistic updates** make quick actions feel instant.

7. **Reusable components** (DataTable, Toolbar) reduce code duplication.

---

## Phase 2 Complete!

You've now completed Phase 2! You've built:

✅ Generic views and ViewSets
✅ Advanced filtering with django-filter
✅ Pagination
✅ Next.js routing and navigation
✅ Frontend data architecture with React Query
✅ Searchable data interfaces

In **Phase 3**, we'll add authentication and authorization:
- JWT authentication
- Login and registration
- Protected routes
- Permissions and roles
- API security

---

**End of Part 13**

*Next: Phase 3 - Authentication, Authorization & Application Security*
