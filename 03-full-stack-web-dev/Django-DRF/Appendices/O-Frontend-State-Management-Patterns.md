# Appendix O: Frontend State Management Patterns

## Comprehensive Guide to State Management in React/Next.js

Welcome to **Appendix O** of the Django REST Framework & Next.js 16 masterclass. This appendix provides a comprehensive guide to state management patterns in React and Next.js, covering everything from local state to global state solutions.

---

## Section 1: Types of State

### 1.1 Local State

```tsx
'use client';

import { useState } from 'react';

// Component-specific state
export function TaskCounter() {
    const [count, setCount] = useState(0);
    
    return (
        <button onClick={() => setCount(c => c + 1)}>
            Count: {count}
        </button>
    );
}
```

### 1.2 URL State (Search Params)

```tsx
// State stored in URL - shareable, bookmarkable
'use client';

import { useSearchParams, useRouter } from 'next/navigation';

export function TaskFilters() {
    const router = useRouter();
    const searchParams = useSearchParams();
    const status = searchParams.get('status') || '';
    
    const updateFilter = (key: string, value: string) => {
        const params = new URLSearchParams(searchParams);
        if (value) {
            params.set(key, value);
        } else {
            params.delete(key);
        }
        router.push(`?${params.toString()}`);
    };
    
    return (
        <select
            value={status}
            onChange={(e) => updateFilter('status', e.target.value)}
        >
            <option value="">All</option>
            <option value="todo">To Do</option>
            <option value="in_progress">In Progress</option>
            <option value="done">Done</option>
        </select>
    );
}
```

### 1.3 Form State

```tsx
'use client';

import { useState } from 'react';

// Form state with validation
export function TaskForm() {
    const [formData, setFormData] = useState({
        title: '',
        description: '',
        status: 'todo',
    });
    
    const [errors, setErrors] = useState<Record<string, string>>({});
    
    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const { name, value } = e.target;
        setFormData(prev => ({ ...prev, [name]: value }));
        
        // Clear error on change
        if (errors[name]) {
            setErrors(prev => ({ ...prev, [name]: '' }));
        }
    };
    
    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        // Validate and submit
    };
    
    return (
        <form onSubmit={handleSubmit}>
            <input
                name="title"
                value={formData.title}
                onChange={handleChange}
                placeholder="Task title"
            />
            {errors.title && <span className="error">{errors.title}</span>}
            {/* ... more fields */}
        </form>
    );
}
```

### 1.4 Server State (API Data)

```tsx
// Server state managed by React Query
'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

export function TaskList() {
    const queryClient = useQueryClient();
    
    // Fetch tasks
    const { data: tasks, isLoading } = useQuery({
        queryKey: ['tasks'],
        queryFn: () => fetch('/api/v1/tasks/').then(res => res.json()),
    });
    
    // Update task
    const { mutate: updateTask } = useMutation({
        mutationFn: (data) => 
            fetch(`/api/v1/tasks/${data.id}/`, {
                method: 'PATCH',
                body: JSON.stringify(data),
            }).then(res => res.json()),
        onSuccess: () => {
            // Invalidate and refetch
            queryClient.invalidateQueries({ queryKey: ['tasks'] });
        },
    });
    
    // ... render tasks
}
```

---

## Section 2: State Management Patterns

### 2.1 Context API (Global State)

```tsx
// lib/context/ThemeContext.tsx
'use client';

import { createContext, useContext, useState, ReactNode } from 'react';

interface ThemeContextType {
    theme: 'light' | 'dark';
    toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export function ThemeProvider({ children }: { children: ReactNode }) {
    const [theme, setTheme] = useState<'light' | 'dark'>('light');
    
    const toggleTheme = () => {
        setTheme(prev => prev === 'light' ? 'dark' : 'light');
    };
    
    return (
        <ThemeContext.Provider value={{ theme, toggleTheme }}>
            {children}
        </ThemeContext.Provider>
    );
}

export function useTheme() {
    const context = useContext(ThemeContext);
    if (!context) {
        throw new Error('useTheme must be used within ThemeProvider');
    }
    return context;
}
```

### 2.2 Zustand (Lightweight State Management)

```tsx
// store/taskStore.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface Task {
    id: number;
    title: string;
    status: string;
}

interface TaskStore {
    tasks: Task[];
    filter: string;
    setTasks: (tasks: Task[]) => void;
    addTask: (task: Task) => void;
    updateTask: (id: number, data: Partial<Task>) => void;
    deleteTask: (id: number) => void;
    setFilter: (filter: string) => void;
    getFilteredTasks: () => Task[];
}

export const useTaskStore = create<TaskStore>()(
    persist(
        (set, get) => ({
            tasks: [],
            filter: 'all',
            
            setTasks: (tasks) => set({ tasks }),
            
            addTask: (task) => set((state) => ({
                tasks: [...state.tasks, task]
            })),
            
            updateTask: (id, data) => set((state) => ({
                tasks: state.tasks.map(task =>
                    task.id === id ? { ...task, ...data } : task
                )
            })),
            
            deleteTask: (id) => set((state) => ({
                tasks: state.tasks.filter(task => task.id !== id)
            })),
            
            setFilter: (filter) => set({ filter }),
            
            getFilteredTasks: () => {
                const { tasks, filter } = get();
                if (filter === 'all') return tasks;
                return tasks.filter(task => task.status === filter);
            },
        }),
        {
            name: 'task-storage', // persist to localStorage
        }
    )
);
```

### 2.3 Redux Toolkit (Complex State)

```tsx
// store/taskSlice.ts
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import { fetchTasks as fetchTasksAPI } from '@/lib/api';

interface TaskState {
    items: Task[];
    status: 'idle' | 'loading' | 'succeeded' | 'failed';
    error: string | null;
}

const initialState: TaskState = {
    items: [],
    status: 'idle',
    error: null,
};

export const fetchTasks = createAsyncThunk(
    'tasks/fetchTasks',
    async () => {
        const response = await fetchTasksAPI();
        return response.data;
    }
);

const taskSlice = createSlice({
    name: 'tasks',
    initialState,
    reducers: {
        addTask: (state, action) => {
            state.items.push(action.payload);
        },
        updateTask: (state, action) => {
            const index = state.items.findIndex(t => t.id === action.payload.id);
            if (index !== -1) {
                state.items[index] = action.payload;
            }
        },
        deleteTask: (state, action) => {
            state.items = state.items.filter(t => t.id !== action.payload);
        },
    },
    extraReducers: (builder) => {
        builder
            .addCase(fetchTasks.pending, (state) => {
                state.status = 'loading';
            })
            .addCase(fetchTasks.fulfilled, (state, action) => {
                state.status = 'succeeded';
                state.items = action.payload;
            })
            .addCase(fetchTasks.rejected, (state, action) => {
                state.status = 'failed';
                state.error = action.error.message || 'Failed to fetch tasks';
            });
    },
});

export const { addTask, updateTask, deleteTask } = taskSlice.actions;
export default taskSlice.reducer;
```

---

## Section 3: State Management Best Practices

### 3.1 State Colocation

```tsx
// ❌ Bad: Global state for everything
const GlobalState = createContext<{ count: number }>({ count: 0 });

// ✅ Good: State as close to where it's used
function Counter() {
    const [count, setCount] = useState(0);
    return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

### 3.2 Derived State

```tsx
// ❌ Bad: Storing derived state
const [tasks, setTasks] = useState([]);
const [completedTasks, setCompletedTasks] = useState([]);

useEffect(() => {
    setCompletedTasks(tasks.filter(t => t.status === 'done'));
}, [tasks]);

// ✅ Good: Derive on render
const tasks = useTasks();
const completedTasks = tasks.filter(t => t.status === 'done');
```

### 3.3 State Normalization

```tsx
// ❌ Bad: Nested state
const state = {
    projects: [
        {
            id: 1,
            tasks: [
                { id: 1, title: 'Task 1' },
                { id: 2, title: 'Task 2' },
            ]
        }
    ]
};

// ✅ Good: Normalized state
const state = {
    projects: {
        byId: {
            1: { id: 1, name: 'Project 1', taskIds: [1, 2] },
        },
        allIds: [1],
    },
    tasks: {
        byId: {
            1: { id: 1, title: 'Task 1', projectId: 1 },
            2: { id: 2, title: 'Task 2', projectId: 1 },
        },
        allIds: [1, 2],
    },
};
```

### 3.4 Immutable Updates

```tsx
// ❌ Bad: Mutating state directly
const state = { tasks: [] };
state.tasks.push(newTask);  // Mutation

// ✅ Good: Creating new objects
setState(prev => ({
    ...prev,
    tasks: [...prev.tasks, newTask]
}));

// ✅ With Immer (Zustand/Redux Toolkit)
setState(produce((draft) => {
    draft.tasks.push(newTask);
}));
```

---

## Section 4: React Query Patterns

### 4.1 Query Configuration

```tsx
// Centralized query configuration
export const queryConfig = {
    defaultOptions: {
        queries: {
            staleTime: 60 * 1000, // 1 minute
            gcTime: 5 * 60 * 1000, // 5 minutes
            retry: 1,
            refetchOnWindowFocus: false,
            refetchOnReconnect: false,
        },
    },
};

// Usage
const queryClient = new QueryClient(queryConfig);
```

### 4.2 Custom Query Hooks

```tsx
// hooks/useTasks.ts
export function useTasks(filters: TaskFilters = {}) {
    return useQuery({
        queryKey: ['tasks', filters],
        queryFn: () => fetchTasks(filters),
        select: (data) => data.results,
        placeholderData: keepPreviousData,
    });
}

// hooks/useTask.ts
export function useTask(id: number) {
    return useQuery({
        queryKey: ['task', id],
        queryFn: () => fetchTask(id),
        enabled: !!id,
        staleTime: Infinity, // Never stale
    });
}
```

### 4.3 Optimistic Updates

```tsx
// Mutation with optimistic update
export function useUpdateTask() {
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
                return {
                    ...old,
                    results: old.results.map((task: Task) =>
                        task.id === newTask.id ? newTask : task
                    )
                };
            });
            
            return { previousTasks };
        },
        
        onError: (err, newTask, context) => {
            // Rollback on error
            queryClient.setQueryData(['tasks'], context?.previousTasks);
        },
        
        onSettled: () => {
            // Always refetch
            queryClient.invalidateQueries({ queryKey: ['tasks'] });
        },
    });
}
```

### 4.4 Infinite Queries

```tsx
export function useInfiniteTasks(filters: TaskFilters = {}) {
    return useInfiniteQuery({
        queryKey: ['tasks', filters],
        queryFn: ({ pageParam = 1 }) => fetchTasks({ ...filters, page: pageParam }),
        getNextPageParam: (lastPage) => lastPage.next_page || undefined,
        initialPageParam: 1,
    });
}

// Usage
function TaskList() {
    const { data, fetchNextPage, hasNextPage, isFetchingNextPage } = useInfiniteTasks();
    
    return (
        <div>
            {data?.pages.map((page) =>
                page.results.map((task: Task) => (
                    <TaskItem key={task.id} task={task} />
                ))
            )}
            {hasNextPage && (
                <button onClick={() => fetchNextPage()} disabled={isFetchingNextPage}>
                    Load More
                </button>
            )}
        </div>
    );
}
```

---

## Section 5: Performance Considerations

### 5.1 Memoization

```tsx
// Memoize expensive calculations
const expensiveValue = useMemo(() => {
    return tasks.filter(t => t.status === 'done').length;
}, [tasks]);

// Memoize callbacks
const handleUpdate = useCallback((id: number) => {
    updateTask(id);
}, [updateTask]);

// Memoize components
const TaskItem = memo(({ task, onUpdate }: TaskItemProps) => {
    return <div onClick={() => onUpdate(task.id)}>{task.title}</div>;
});
```

### 5.2 Selectors

```tsx
// React Query selector
const { data: completedTasks } = useTasks({
    select: (data) => data.filter((task: Task) => task.status === 'done')
});

// Zustand selector
const completedTasks = useTaskStore(
    (state) => state.tasks.filter(t => t.status === 'done')
);

// Redux selector
const completedTasks = useSelector(
    (state) => state.tasks.items.filter(t => t.status === 'done')
);
```

### 5.3 Batching Updates

```tsx
// React state batching
const [tasks, setTasks] = useState([]);
const [loading, setLoading] = useState(false);

// These will be batched in React 18
setTasks(newTasks);
setLoading(false);

// React Query batch updates
const queryClient = useQueryClient();
queryClient.setQueriesData({ queryKey: ['tasks'] }, newData);
queryClient.invalidateQueries({ queryKey: ['tasks'] });
```

---

## Quick Reference: When to Use What

| State Type | Solution | When to Use |
|------------|----------|-------------|
| **Local UI State** | `useState` | Component-specific, non-shared state |
| **URL State** | `useSearchParams` | Filters, pagination, shareable state |
| **Form State** | `useState` + validation | Complex forms |
| **Global UI State** | Context API | Theme, user preferences |
| **App State** | Zustand/Redux | Complex, shared state across app |
| **Server State** | React Query/SWR | API data, caching, mutations |
| **Optimistic Updates** | React Query/SWR | Better UX for mutations |
| **Persistence** | localStorage, cookies | User preferences, auth |

---

*This concludes Appendix O. Keep this reference handy for state management decisions.*
