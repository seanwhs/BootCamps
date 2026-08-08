# Part 10: Pagination

## Handling Large Datasets Efficiently

Welcome to **Part 10** of the Django REST Framework & Next.js 16 masterclass. Now that we have advanced filtering and search capabilities, it's time to add pagination. Pagination is essential for handling large datasets efficiently, improving performance, and providing a better user experience.

In this part, we'll:
- Understand different pagination strategies
- Implement page-based pagination
- Add custom pagination classes
- Return pagination metadata
- Build frontend pagination controls
- Implement infinite scrolling

Think of pagination as **chunking** your data. Instead of sending all 10,000 tasks to the client at once, you send them in manageable pages of 20 at a time. This improves load times, reduces bandwidth usage, and makes your application more responsive.

---

## The Target

We'll implement pagination across all list endpoints:

```
GET /api/v1/tasks/
{
    "count": 100,              # Total number of tasks
    "next": "http://...?page=2",  # URL to next page
    "previous": null,          # URL to previous page
    "results": [ ... ]         # Page of 20 tasks
}

GET /api/v1/tasks/?page=2
GET /api/v1/tasks/?page=3&page_size=50
GET /api/v1/tasks/?limit=20&offset=40
```

---

## The Concept

### What is Pagination?

Pagination is the process of splitting a large dataset into smaller, manageable chunks (pages). This is essential for:
- **Performance**: Smaller payloads = faster responses
- **UX**: Users don't want to wait for 10,000 items to load
- **Resource usage**: Reduces memory and CPU usage on both server and client

### Pagination Strategies

DRF provides three main pagination styles:

#### 1. Page Number Pagination

**URL Pattern**: `?page=2`

```
GET /api/tasks/?page=2&page_size=20
```

**Response**:
```json
{
    "count": 100,
    "next": "http://.../tasks/?page=3",
    "previous": "http://.../tasks/?page=1",
    "results": [...]
}
```

**Best for**: Most use cases, especially when you need to jump to specific pages.

#### 2. Limit Offset Pagination

**URL Pattern**: `?limit=20&offset=40`

```
GET /api/tasks/?limit=20&offset=40
```

**Response**:
```json
{
    "count": 100,
    "next": "http://.../tasks/?limit=20&offset=60",
    "previous": "http://.../tasks/?limit=20&offset=20",
    "results": [...]
}
```

**Best for**: When you need to jump to specific positions in the dataset.

#### 3. Cursor Pagination

**URL Pattern**: Uses encoded cursor strings

```
GET /api/tasks/?cursor=cD0yMDI2LTAxLTE1KzEyJTNBMDAlM0EwMCUyQjAwJTNB...
```

**Response**:
```json
{
    "next": "http://.../tasks/?cursor=cD0yMDI2LTAxLTE2...",
    "previous": null,
    "results": [...]
}
```

**Best for**: Large datasets, infinite scrolling, and when you need consistency (doesn't skip items if data changes between requests).

---

## The Implementation

### Step 1: Create Custom Pagination Classes

**backend/apps/api/pagination.py** (create this file)

```python
"""
Custom pagination classes for the API.
"""

from rest_framework import pagination
from rest_framework.response import Response


class CustomPageNumberPagination(pagination.PageNumberPagination):
    """
    Custom page number pagination with configurable page size.
    """
    
    # Default page size
    page_size = 20
    
    # Allow client to override the page size
    page_size_query_param = 'page_size'
    
    # Maximum page size the client can request
    max_page_size = 100
    
    # The name of the page query parameter
    page_query_param = 'page'
    
    def get_paginated_response(self, data):
        """
        Customize the pagination response format.
        """
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


class CustomLimitOffsetPagination(pagination.LimitOffsetPagination):
    """
    Custom limit-offset pagination with configurable limits.
    """
    
    # Default limit
    default_limit = 20
    
    # Allow client to override the limit
    limit_query_param = 'limit'
    
    # Allow client to set the offset
    offset_query_param = 'offset'
    
    # Maximum limit the client can request
    max_limit = 100
    
    def get_paginated_response(self, data):
        """
        Customize the pagination response format.
        """
        return Response({
            'links': {
                'next': self.get_next_link(),
                'previous': self.get_previous_link(),
            },
            'count': self.count,
            'limit': self.limit,
            'offset': self.offset,
            'results': data,
        })


class CustomCursorPagination(pagination.CursorPagination):
    """
    Custom cursor pagination for infinite scrolling.
    """
    
    # Ordering field
    ordering = '-created_at'
    
    # The name of the cursor query parameter
    cursor_query_param = 'cursor'
    
    # Page size
    page_size = 20
    
    # Allow client to override the page size
    page_size_query_param = 'page_size'
    
    # Maximum page size
    max_page_size = 100
    
    def get_paginated_response(self, data):
        """
        Customize the pagination response format.
        """
        return Response({
            'links': {
                'next': self.get_next_link(),
                'previous': self.get_previous_link(),
            },
            'page_size': self.page_size,
            'results': data,
        })
```

### Step 2: Update Settings

**backend/config/settings.py** (update pagination settings)

```python
# In REST_FRAMEWORK settings
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',  # Will change in Phase 3
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
        'rest_framework.renderers.BrowsableAPIRenderer',
    ],
    'DEFAULT_PARSER_CLASSES': [
        'rest_framework.parsers.JSONParser',
    ],
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
    # Use custom pagination class
    'DEFAULT_PAGINATION_CLASS': 'apps.api.pagination.CustomPageNumberPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_VERSIONING_CLASS': 'rest_framework.versioning.URLPathVersioning',
    'DEFAULT_VERSION': 'v1',
    'ALLOWED_VERSIONS': ['v1'],
    'VERSION_PARAM': 'version',
}
```

### Step 3: Update ViewSets with Pagination

**backend/apps/tasks/views.py** (update)

```python
"""
API views for Task management with pagination.
"""

from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import AllowAny

from .models import Task
from .serializers import (
    TaskSerializer,
    TaskCreateSerializer,
    TaskUpdateSerializer,
    TaskStatusUpdateSerializer,
)
from .filters import TaskFilter


class TaskViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Task CRUD operations with pagination and filtering.
    """
    
    queryset = Task.objects.all()
    permission_classes = [AllowAny]  # Will change in Phase 3
    
    # Filter backends
    filter_backends = [
        DjangoFilterBackend,
        filters.SearchFilter,
        filters.OrderingFilter,
    ]
    
    # Use our custom filter class
    filterset_class = TaskFilter
    
    # Search fields
    search_fields = ['title', 'description']
    
    # Ordering fields
    ordering_fields = [
        'created_at', 'updated_at', 'due_date',
        'priority', 'status', 'title'
    ]
    ordering = ['-created_at']
    
    # Pagination is handled by the global setting
    # But we can override it per view if needed
    
    def get_serializer_class(self):
        """
        Return different serializers based on the action.
        """
        if self.action == 'create':
            return TaskCreateSerializer
        elif self.action in ['update', 'partial_update']:
            if self.action == 'partial_update' and 'status' in self.request.data:
                return TaskStatusUpdateSerializer
            return TaskUpdateSerializer
        elif self.action == 'status':
            return TaskStatusUpdateSerializer
        return TaskSerializer
    
    def perform_create(self, serializer):
        """
        Set the created_by field when creating a task.
        """
        from apps.users.models import User
        user = User.objects.first()  # Will be updated with auth
        serializer.save(created_by=user)
    
    @action(detail=True, methods=['patch'])
    def status(self, request, pk=None):
        """
        Update only the status of a task.
        """
        task = self.get_object()
        serializer = TaskStatusUpdateSerializer(task, data=request.data)
        if serializer.is_valid():
            serializer.save()
            response_serializer = TaskSerializer(task)
            return Response(response_serializer.data)
        return Response(
            serializer.errors,
            status=status.HTTP_400_BAD_REQUEST
        )
    
    @action(detail=True, methods=['get'])
    def comments(self, request, pk=None):
        """
        Get all comments for a task with pagination.
        """
        task = self.get_object()
        comments = task.comments.all()
        
        # Apply comment filters
        from apps.comments.filters import CommentFilter
        filter_set = CommentFilter(
            request.query_params,
            queryset=comments,
            request=request
        )
        if filter_set.is_valid():
            comments = filter_set.qs
        
        # Apply pagination
        from rest_framework.pagination import PageNumberPagination
        paginator = PageNumberPagination()
        paginator.page_size = 10  # Smaller page size for comments
        
        # For nested resources, we use the paginator manually
        page = paginator.paginate_queryset(comments, request)
        
        from apps.comments.serializers import CommentSerializer
        serializer = CommentSerializer(page, many=True)
        return paginator.get_paginated_response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def stats(self, request):
        """
        Get task statistics (no pagination).
        """
        # Apply filters to get accurate stats
        filtered_queryset = self.filter_queryset(self.get_queryset())
        
        from django.utils import timezone
        now = timezone.now()
        
        stats = {
            'total': filtered_queryset.count(),
            'todo': filtered_queryset.filter(status='todo').count(),
            'in_progress': filtered_queryset.filter(status='in_progress').count(),
            'review': filtered_queryset.filter(status='review').count(),
            'done': filtered_queryset.filter(status='done').count(),
            'overdue': filtered_queryset.filter(
                due_date__lt=now,
                status__in=['todo', 'in_progress', 'review']
            ).count(),
            'by_priority': {
                'low': filtered_queryset.filter(priority='low').count(),
                'medium': filtered_queryset.filter(priority='medium').count(),
                'high': filtered_queryset.filter(priority='high').count(),
                'urgent': filtered_queryset.filter(priority='urgent').count(),
            }
        }
        
        return Response(stats)
    
    @action(detail=False, methods=['get'])
    def all(self, request):
        """
        Get all tasks without pagination (for exports/analytics).
        This endpoint returns all tasks without pagination.
        """
        queryset = self.filter_queryset(self.get_queryset())
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)
```

### Step 4: Create Paginated Response Types for Frontend

**frontend/types/index.ts** (update)

```typescript
// ... existing types ...

/**
 * Paginated response type
 */
export interface PaginatedResponse<T> {
  links: {
    next: string | null;
    previous: string | null;
  };
  count: number;
  page_size: number;
  current_page: number;
  total_pages: number;
  results: T[];
}

/**
 * Pagination parameters
 */
export interface PaginationParams {
  page?: number;
  page_size?: number;
  limit?: number;
  offset?: number;
}
```

### Step 5: Update Frontend API Client

**frontend/lib/api/client.ts** (update)

```typescript
/**
 * API client with pagination support
 */

import { API_BASE_URL } from '@/lib/utils/constants';
import { PaginatedResponse, PaginationParams } from '@/types';

export interface ApiError {
  detail?: string;
  [key: string]: any;
}

export interface ApiResponse<T = any> {
  data?: T;
  error?: ApiError;
  status: number;
}

/**
 * Build URL with query parameters
 */
function buildUrl(endpoint: string, params?: Record<string, any>): string {
  const url = new URL(`${API_BASE_URL}${endpoint}`);
  if (params) {
    Object.entries(params).forEach(([key, value]) => {
      if (value !== undefined && value !== null && value !== '') {
        url.searchParams.append(key, String(value));
      }
    });
  }
  return url.toString();
}

/**
 * Make an API request
 */
export async function apiRequest<T = any>(
  endpoint: string,
  options: RequestInit = {},
  params?: Record<string, any>
): Promise<ApiResponse<T>> {
  const url = buildUrl(endpoint, params);
  const headers: HeadersInit = {
    'Content-Type': 'application/json',
    ...options.headers,
  };

  try {
    const response = await fetch(url, {
      ...options,
      headers,
    });

    let data;
    const contentType = response.headers.get('content-type');
    if (contentType && contentType.includes('application/json')) {
      data = await response.json();
    } else {
      data = await response.text();
    }

    if (!response.ok) {
      return {
        error: data as ApiError,
        status: response.status,
      };
    }

    return {
      data: data as T,
      status: response.status,
    };
  } catch (error) {
    console.error('API request failed:', error);
    return {
      error: {
        detail: 'Network error. Please check your connection.',
      },
      status: 0,
    };
  }
}

/**
 * GET request with pagination support
 */
export async function getPaginated<T = any>(
  endpoint: string,
  params?: PaginationParams & Record<string, any>
): Promise<ApiResponse<PaginatedResponse<T>>> {
  return apiRequest<PaginatedResponse<T>>(endpoint, { method: 'GET' }, params);
}

/**
 * GET request (for non-paginated endpoints)
 */
export async function get<T = any>(
  endpoint: string,
  params?: Record<string, any>
): Promise<ApiResponse<T>> {
  return apiRequest<T>(endpoint, { method: 'GET' }, params);
}

/**
 * POST request
 */
export async function post<T = any>(
  endpoint: string,
  data?: any,
  params?: Record<string, any>
): Promise<ApiResponse<T>> {
  return apiRequest<T>(
    endpoint,
    {
      method: 'POST',
      body: data ? JSON.stringify(data) : undefined,
    },
    params
  );
}

/**
 * PUT request
 */
export async function put<T = any>(
  endpoint: string,
  data?: any,
  params?: Record<string, any>
): Promise<ApiResponse<T>> {
  return apiRequest<T>(
    endpoint,
    {
      method: 'PUT',
      body: data ? JSON.stringify(data) : undefined,
    },
    params
  );
}

/**
 * PATCH request
 */
export async function patch<T = any>(
  endpoint: string,
  data?: any,
  params?: Record<string, any>
): Promise<ApiResponse<T>> {
  return apiRequest<T>(
    endpoint,
    {
      method: 'PATCH',
      body: data ? JSON.stringify(data) : undefined,
    },
    params
  );
}

/**
 * DELETE request
 */
export async function del<T = any>(
  endpoint: string,
  params?: Record<string, any>
): Promise<ApiResponse<T>> {
  return apiRequest<T>(endpoint, { method: 'DELETE' }, params);
}
```

### Step 6: Update Frontend Data Hooks

**frontend/lib/api/hooks.ts** (update)

```typescript
/**
 * Custom hooks for data fetching with pagination
 */

'use client';

import { useState, useEffect, useCallback } from 'react';
import { getPaginated, get, post, put, patch, del, ApiResponse } from './client';
import { PaginatedResponse, PaginationParams } from '@/types';

interface UseFetchOptions {
  enabled?: boolean;
  initialData?: any;
  params?: Record<string, any>;
}

/**
 * Hook for fetching paginated data
 */
export function usePaginatedFetch<T = any>(
  url: string,
  options: UseFetchOptions = {}
) {
  const { enabled = true, initialData, params = {} } = options;
  const [data, setData] = useState<PaginatedResponse<T> | undefined>(initialData);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [currentParams, setCurrentParams] = useState<Record<string, any>>(params);

  const fetchData = useCallback(async (fetchParams?: Record<string, any>) => {
    if (!enabled) return;
    
    const queryParams = { ...currentParams, ...fetchParams };
    setLoading(true);
    setError(null);
    
    try {
      const response = await getPaginated<T>(url, queryParams);
      
      if (response.error) {
        setError(response.error.detail || 'An error occurred');
      } else {
        setData(response.data);
        // Update current params if they changed
        setCurrentParams(queryParams);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setLoading(false);
    }
  }, [url, enabled, currentParams]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const refetch = useCallback((newParams?: Record<string, any>) => {
    return fetchData(newParams);
  }, [fetchData]);

  const nextPage = useCallback(() => {
    if (data?.links?.next) {
      // Extract page number from next URL
      const url = new URL(data.links.next);
      const page = url.searchParams.get('page');
      if (page) {
        refetch({ page: parseInt(page) });
      }
    }
  }, [data, refetch]);

  const previousPage = useCallback(() => {
    if (data?.links?.previous) {
      const url = new URL(data.links.previous);
      const page = url.searchParams.get('page');
      if (page) {
        refetch({ page: parseInt(page) });
      }
    }
  }, [data, refetch]);

  const goToPage = useCallback((page: number) => {
    refetch({ page });
  }, [refetch]);

  const setFilters = useCallback((filters: Record<string, any>) => {
    const newParams = { ...currentParams, ...filters, page: 1 };
    setCurrentParams(newParams);
    refetch(newParams);
  }, [currentParams, refetch]);

  return { 
    data, 
    loading, 
    error, 
    refetch, 
    nextPage, 
    previousPage, 
    goToPage,
    setFilters,
    currentPage: data?.current_page || 1,
    totalPages: data?.total_pages || 1,
  };
}

/**
 * Hook for fetching data (non-paginated)
 */
export function useFetch<T = any>(
  url: string,
  options: UseFetchOptions = {}
) {
  const { enabled = true, initialData, params = {} } = options;
  const [data, setData] = useState<T | undefined>(initialData);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  const fetchData = useCallback(async () => {
    if (!enabled) return;
    
    setLoading(true);
    setError(null);
    
    try {
      const response = await get<T>(url, params);
      
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
  }, [url, enabled, params]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const refetch = useCallback(() => {
    return fetchData();
  }, [fetchData]);

  return { data, loading, error, refetch };
}

// ... rest of hooks remain the same ...
```

### Step 7: Create Pagination UI Components

**frontend/components/ui/Pagination.tsx**
```tsx
'use client';

import { ChevronLeft, ChevronRight } from 'lucide-react';
import { Button } from './Button';
import { cn } from '@/lib/utils/helpers';

interface PaginationProps {
  currentPage: number;
  totalPages: number;
  onPageChange: (page: number) => void;
  className?: string;
  showPageNumbers?: boolean;
  maxVisiblePages?: number;
}

export function Pagination({
  currentPage,
  totalPages,
  onPageChange,
  className,
  showPageNumbers = true,
  maxVisiblePages = 5,
}: PaginationProps) {
  if (totalPages <= 1) {
    return null;
  }

  const getVisiblePages = () => {
    const pages: number[] = [];
    const half = Math.floor(maxVisiblePages / 2);
    let start = Math.max(1, currentPage - half);
    let end = Math.min(totalPages, start + maxVisiblePages - 1);

    if (end - start < maxVisiblePages - 1) {
      start = Math.max(1, end - maxVisiblePages + 1);
    }

    for (let i = start; i <= end; i++) {
      pages.push(i);
    }
    return pages;
  };

  const visiblePages = getVisiblePages();
  const showEllipsisStart = visiblePages[0] > 1;
  const showEllipsisEnd = visiblePages[visiblePages.length - 1] < totalPages;

  return (
    <nav
      className={cn(
        'flex items-center justify-center gap-1',
        className
      )}
      aria-label="Pagination"
    >
      <Button
        variant="outline"
        size="sm"
        onClick={() => onPageChange(currentPage - 1)}
        disabled={currentPage === 1}
        aria-label="Previous page"
      >
        <ChevronLeft className="h-4 w-4" />
      </Button>

      {showEllipsisStart && (
        <>
          <Button
            variant="outline"
            size="sm"
            onClick={() => onPageChange(1)}
          >
            1
          </Button>
          <span className="px-2 text-secondary-400">…</span>
        </>
      )}

      {showPageNumbers &&
        visiblePages.map((page) => (
          <Button
            key={page}
            variant={page === currentPage ? 'default' : 'outline'}
            size="sm"
            onClick={() => onPageChange(page)}
            aria-current={page === currentPage ? 'page' : undefined}
          >
            {page}
          </Button>
        ))}

      {showEllipsisEnd && (
        <>
          <span className="px-2 text-secondary-400">…</span>
          <Button
            variant="outline"
            size="sm"
            onClick={() => onPageChange(totalPages)}
          >
            {totalPages}
          </Button>
        </>
      )}

      <Button
        variant="outline"
        size="sm"
        onClick={() => onPageChange(currentPage + 1)}
        disabled={currentPage === totalPages}
        aria-label="Next page"
      >
        <ChevronRight className="h-4 w-4" />
      </Button>
    </nav>
  );
}
```

**frontend/components/ui/PageSizeSelector.tsx**
```tsx
'use client';

import { useState } from 'react';

interface PageSizeSelectorProps {
  value: number;
  onChange: (size: number) => void;
  options?: number[];
  className?: string;
}

export function PageSizeSelector({
  value,
  onChange,
  options = [10, 20, 50, 100],
  className,
}: PageSizeSelectorProps) {
  return (
    <div className={className}>
      <label className="text-sm text-secondary-600 mr-2">Show:</label>
      <select
        value={value}
        onChange={(e) => onChange(Number(e.target.value))}
        className="rounded-md border border-secondary-300 bg-white px-2 py-1 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
      >
        {options.map((option) => (
          <option key={option} value={option}>
            {option}
          </option>
        ))}
      </select>
    </div>
  );
}
```

### Step 8: Update Frontend Task List with Pagination

**frontend/app/(dashboard)/tasks/components/TaskList.tsx** (update)

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
import { Pagination } from '@/components/ui/Pagination';
import { PageSizeSelector } from '@/components/ui/PageSizeSelector';
import { usePaginatedFetch } from '@/lib/api/hooks';
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
  
  // Build the URL
  const url = projectId 
    ? ENDPOINTS.projects.tasks(projectId)
    : ENDPOINTS.tasks.list;

  // Fetch tasks with pagination
  const {
    data,
    loading,
    error,
    setFilters,
    goToPage,
    currentPage,
    totalPages,
  } = usePaginatedFetch<Task>(url, {
    initialData: initialTasks ? {
      results: initialTasks,
      count: initialTasks.length,
      current_page: 1,
      total_pages: Math.ceil(initialTasks.length / 20),
      page_size: 20,
      links: { next: null, previous: null }
    } : undefined,
    params: { page_size: 20 }
  });

  const tasks = data?.results || [];
  const totalTasks = data?.count || 0;

  // Apply client-side filters (in addition to server-side)
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

  // Apply filters to API
  const handleFilterChange = (filters: Record<string, any>) => {
    const apiFilters: Record<string, any> = {};
    
    // Map frontend filters to API parameters
    if (statusFilter) {
      apiFilters.status = statusFilter;
    }
    if (searchTerm) {
      apiFilters.search = searchTerm;
    }
    
    // Merge with existing filters
    setFilters(apiFilters);
  };

  // Debounce search
  const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setSearchTerm(value);
    // Apply search after a delay
    clearTimeout((window as any)._searchTimeout);
    (window as any)._searchTimeout = setTimeout(() => {
      handleFilterChange({ search: value });
    }, 300);
  };

  const handleStatusFilterChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const value = e.target.value;
    setStatusFilter(value);
    handleFilterChange({ status: value });
  };

  if (loading && !data) {
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
                handleFilterChange({ search: '' });
              }}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-secondary-400 hover:text-secondary-600"
            >
              <X className="h-4 w-4" />
            </button>
          )}
        </div>
        <select
          value={statusFilter}
          onChange={handleStatusFilterChange}
          className="rounded-md border border-secondary-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
        >
          <option value="">All Statuses</option>
          {statuses.map(status => (
            <option key={status} value={status}>
              {TASK_STATUS_LABELS[status]}
            </option>
          ))}
        </select>
        <PageSizeSelector
          value={data?.page_size || 20}
          onChange={(size) => setFilters({ page_size: size, page: 1 })}
        />
        {statusFilter && (
          <Button
            variant="ghost"
            size="sm"
            onClick={() => {
              setStatusFilter('');
              handleFilterChange({ status: '' });
            }}
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
              {tasks.length === 0 ? 'No tasks yet' : 'No tasks match your filters'}
            </p>
          </CardContent>
        </Card>
      ) : (
        <>
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

          {/* Pagination */}
          {totalPages > 1 && (
            <div className="flex items-center justify-between pt-4">
              <Pagination
                currentPage={currentPage}
                totalPages={totalPages}
                onPageChange={goToPage}
              />
              <span className="text-sm text-secondary-500">
                Showing {((currentPage - 1) * (data?.page_size || 20)) + 1} -{' '}
                {Math.min(currentPage * (data?.page_size || 20), totalTasks)} of {totalTasks}
              </span>
            </div>
          )}
        </>
      )}
    </div>
  );
}
```

### Step 9: Update Project Detail Page to Use Paginated Tasks

**frontend/app/(dashboard)/projects/[id]/page.tsx** (update the tasks section)

```tsx
// In the project detail page, update the tasks section to use the TaskList component
// with pagination support

import { TaskList } from '@/app/(dashboard)/tasks/components/TaskList';

// In the render section, replace the existing task list with:
<TaskList projectId={project.id} />
```

---

## The Verification

### Step 1: Start the Server

```bash
cd backend
source venv/bin/activate
python manage.py runserver
```

### Step 2: Start the Frontend

```bash
cd frontend
npm run dev
```

### Step 3: Test API Pagination

```bash# Get first page (default 20 items)
curl -X GET http://localhost:8000/api/v1/tasks/

# Get second page
curl -X GET "http://localhost:8000/api/v1/tasks/?page=2"

# Change page size
curl -X GET "http://localhost:8000/api/v1/tasks/?page=1&page_size=50"

# Test limit-offset pagination (if configured)
curl -X GET "http://localhost:8000/api/v1/tasks/?limit=10&offset=20"

# Verify pagination metadata
curl -X GET "http://localhost:8000/api/v1/tasks/?page=2" | python -m json.tool

# Expected response structure:
# {
#   "links": {
#     "next": "http://localhost:8000/api/v1/tasks/?page=3",
#     "previous": "http://localhost:8000/api/v1/tasks/?page=1"
#   },
#   "count": 100,
#   "page_size": 20,
#   "current_page": 2,
#   "total_pages": 5,
#   "results": [...]
# }
```

### Step 4: Test Combined Filters with Pagination

```bash
# Filter and paginate
curl -X GET "http://localhost:8000/api/v1/tasks/?status=in_progress&page=2&page_size=10"

# Search and paginate
curl -X GET "http://localhost:8000/api/v1/tasks/?search=api&page=1&page_size=5"

# Order and paginate
curl -X GET "http://localhost:8000/api/v1/tasks/?ordering=-priority&page=2"
```

### Step 5: Test Frontend Pagination

1. Go to http://localhost:3000/tasks
2. You should see tasks with pagination controls
3. Click "Next" to go to the next page
4. Click page numbers to navigate
5. Change page size using the dropdown
6. Apply filters and verify pagination updates

### Step 6: Test Performance

```bash
# Create many tasks (if you don't have many)
# In Django shell:
python manage.py shell
from apps.tasks.models import Task
from apps.projects.models import Project

project = Project.objects.first()
for i in range(50):
    Task.objects.create(
        title=f"Test Task {i}",
        project=project,
        created_by=project.created_by
    )

# Test with small page size
time curl -X GET "http://localhost:8000/api/v1/tasks/?page_size=5"

# Test with large page size
time curl -X GET "http://localhost:8000/api/v1/tasks/?page_size=100"

# Compare response times - pagination should be faster for large datasets
```

---

## Key Takeaways

1. **Pagination is essential** for performance, UX, and resource management.

2. **Page number pagination** is the most common and intuitive for users.

3. **Limit-offset pagination** offers more control for complex queries.

4. **Cursor pagination** is best for infinite scrolling and consistent results.

5. **Custom pagination classes** allow you to control the response format.

6. **Frontend pagination** should include:
   - Page numbers or next/prev buttons
   - Page size selector
   - Item count display

7. **Filtering and pagination work together** - filters should affect the total count and pages.

8. **Nested resources** (like task comments) should also be paginated.

9. **Stats endpoints** typically don't need pagination since they return aggregates.

10. **The browsable API** shows pagination controls automatically.

---

## What's Next

In **Part 11**, we'll implement Next.js routing and navigation. You'll learn:

- Dynamic routes and nested routes
- Route groups for organization
- Layouts and layouts nesting
- Loading UI and error boundaries
- Navigation between pages

---

**End of Part 10**

*Next: Part 11 - Next.js Routing & Navigation*
