# Appendix E: Zustand Ecosystem & Integrations

Zustand is a small library, but it integrates seamlessly with the broader React ecosystem. This appendix covers how Zustand works with popular libraries and frameworks, including React Query, React Router, Next.js, Redux DevTools, and more.

---

## Quick Integration Matrix

| Integration | Purpose | Complexity | Recommended |
|-------------|---------|------------|-------------|
| **React Query** | Server state + caching | Low | ✅ Yes |
| **React Router** | URL state sync | Medium | ✅ Yes |
| **Next.js** | SSR + App Router | Medium | ✅ Yes |
| **Redux DevTools** | Debugging | Low | ✅ Yes |
| **Immer** | Immutable updates | Low | ✅ Yes |
| **Reselect** | Memoized selectors | Low | ✅ Yes |
| **React Hook Form** | Form state | Medium | ✅ Yes |
| **Framer Motion** | Animations | Medium | ✅ Yes |
| **React Native** | Mobile | Low | ✅ Yes |
| **Expo** | React Native + Expo | Low | ✅ Yes |
| **Vite** | Build tool | Low | ✅ Yes |
| **Next.js (Server Components)** | SSR + RSC | Medium | ✅ Yes |

---

## Integration 1: Zustand + React Query (Server State)

### When to Use Together

| Zustand | React Query |
|---------|-------------|
| Client-only state | Server state |
| UI state (theme, modals) | API data (tasks, users) |
| Form state | Cache management |
| Optimistic updates | Background refetching |
| Local persistence | Server synchronization |

### Basic Setup

```typescript
// app/providers.tsx
'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import { useState } from 'react';

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 60 * 1000,
            gcTime: 5 * 60 * 1000,
            refetchOnWindowFocus: false,
          },
        },
      })
  );

  return (
    <QueryClientProvider client={queryClient}>
      {children}
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  );
}
```

### Store with React Query Integration

```typescript
// store/taskStore.ts (Client-only state)
import { create } from 'zustand';

interface TaskStore {
  selectedTaskId: string | null;
  filters: TaskFilters;
  searchQuery: string;
  setSelectedTask: (id: string | null) => void;
  setFilters: (filters: Partial<TaskFilters>) => void;
  setSearchQuery: (query: string) => void;
}

export const useTaskStore = create<TaskStore>((set) => ({
  selectedTaskId: null,
  filters: { status: 'all', priority: 'all' },
  searchQuery: '',
  setSelectedTask: (selectedTaskId) => set({ selectedTaskId }),
  setFilters: (filters) =>
    set((state) => ({ filters: { ...state.filters, ...filters } })),
  setSearchQuery: (searchQuery) => set({ searchQuery }),
}));

// hooks/useTasks.ts (Server state with React Query)
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { taskApi } from '../services/taskApi';

export function useTasks(filters?: TaskFilters) {
  return useQuery({
    queryKey: ['tasks', filters],
    queryFn: () => taskApi.getTasks(filters),
  });
}

export function useTaskMutations() {
  const queryClient = useQueryClient();

  const createTask = useMutation({
    mutationFn: taskApi.createTask,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tasks'] });
    },
  });

  const updateTask = useMutation({
    mutationFn: ({ id, updates }) => taskApi.updateTask(id, updates),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tasks'] });
    },
  });

  const deleteTask = useMutation({
    mutationFn: taskApi.deleteTask,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tasks'] });
    },
  });

  return { createTask, updateTask, deleteTask };
}

// Component combining both
function TaskList() {
  // React Query for server data
  const { data: tasks, isLoading } = useTasks();
  // Zustand for client state
  const { selectedTaskId, setSelectedTask } = useTaskStore();
  const { updateTask, deleteTask } = useTaskMutations();

  if (isLoading) return <div>Loading...</div>;

  return tasks?.map((task) => (
    <div
      key={task.id}
      className={task.id === selectedTaskId ? 'selected' : ''}
      onClick={() => setSelectedTask(task.id)}
    >
      <span>{task.title}</span>
      <button onClick={() => updateTask.mutate({ id: task.id, updates: { completed: !task.completed } })}>
        Toggle
      </button>
      <button onClick={() => deleteTask.mutate(task.id)}>Delete</button>
    </div>
  ));
}
```

---

## Integration 2: Zustand + React Router (URL State Sync)

### Sync Store with URL Params

```typescript
// store/routerStore.ts
import { create } from 'zustand';
import { useSearchParams } from 'react-router-dom';

interface RouterStore {
  params: URLSearchParams;
  setParam: (key: string, value: string) => void;
  getParam: (key: string) => string | null;
}

export const useRouterStore = create<RouterStore>((set, get) => ({
  params: new URLSearchParams(),
  setParam: (key, value) => {
    const params = new URLSearchParams(get().params);
    if (value) {
      params.set(key, value);
    } else {
      params.delete(key);
    }
    set({ params });
    // Update URL
    const url = new URL(window.location.href);
    url.search = params.toString();
    window.history.pushState({}, '', url);
  },
  getParam: (key) => get().params.get(key),
}));

// Hook to sync router with store
export function useSyncRouterStore() {
  const [searchParams, setSearchParams] = useSearchParams();
  const setParam = useRouterStore((state) => state.setParam);

  // Sync URL params to store on navigation
  useEffect(() => {
    const params = new URLSearchParams(searchParams);
    const store = useRouterStore.getState();
    store.params = params;
  }, [searchParams]);

  // Intercept setParam to update URL
  const originalSetParam = useRouterStore.getState().setParam;
  useRouterStore.setState({
    setParam: (key, value) => {
      originalSetParam(key, value);
      setSearchParams((params) => {
        if (value) {
          params.set(key, value);
        } else {
          params.delete(key);
        }
        return params;
      });
    },
  });
}

// Component using URL state
function TaskList() {
  const getParam = useRouterStore((state) => state.getParam);
  const setParam = useRouterStore((state) => state.setParam);

  const filter = getParam('filter') || 'all';
  const page = Number(getParam('page')) || 1;

  return (
    <div>
      <select
        value={filter}
        onChange={(e) => setParam('filter', e.target.value)}
      >
        <option value="all">All</option>
        <option value="active">Active</option>
        <option value="completed">Completed</option>
      </select>

      <button
        onClick={() => setParam('page', String(page + 1))}
        disabled={page === 1}
      >
        Previous
      </button>
      <span>Page {page}</span>
      <button onClick={() => setParam('page', String(page + 1))}>Next</button>
    </div>
  );
}
```

---

## Integration 3: Zustand + React Hook Form

### Form State with Zustand and React Hook Form

```typescript
// store/formStore.ts
import { create } from 'zustand';

interface FormStore {
  formData: Record<string, any>;
  isSubmitting: boolean;
  errors: Record<string, string>;
  setField: (name: string, value: any) => void;
  setErrors: (errors: Record<string, string>) => void;
  setSubmitting: (isSubmitting: boolean) => void;
  resetForm: () => void;
}

export const useFormStore = create<FormStore>((set) => ({
  formData: {},
  isSubmitting: false,
  errors: {},
  setField: (name, value) =>
    set((state) => ({
      formData: { ...state.formData, [name]: value },
    })),
  setErrors: (errors) => set({ errors }),
  setSubmitting: (isSubmitting) => set({ isSubmitting }),
  resetForm: () => set({ formData: {}, errors: {}, isSubmitting: false }),
}));

// Component with React Hook Form + Zustand
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const schema = z.object({
  title: z.string().min(1, 'Title is required'),
  description: z.string().optional(),
  priority: z.enum(['low', 'medium', 'high']),
});

function TaskForm() {
  const { formData, setField, isSubmitting, setSubmitting, errors, setErrors, resetForm } = useFormStore();
  const { handleSubmit, control, reset } = useForm({
    resolver: zodResolver(schema),
    defaultValues: formData,
  });

  const onSubmit = async (data) => {
    setSubmitting(true);
    try {
      await taskApi.createTask(data);
      resetForm();
      reset();
    } catch (error) {
      setErrors({ submit: error.message });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <Controller
        name="title"
        control={control}
        render={({ field }) => (
          <input
            {...field}
            onChange={(e) => {
              field.onChange(e);
              setField('title', e.target.value);
            }}
          />
        )}
      />
      {/* ... other fields */}
      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Submitting...' : 'Submit'}
      </button>
    </form>
  );
}
```

---

## Integration 4: Zustand + Framer Motion (Animations)

### Animate State Changes with Framer Motion

```tsx
import { motion, AnimatePresence } from 'framer-motion';
import { useTaskStore } from '../store/taskStore';

function AnimatedTaskList() {
  const tasks = useTaskStore((state) => state.tasks);
  const toggleTask = useTaskStore((state) => state.toggleTask);

  return (
    <AnimatePresence>
      {tasks.map((task) => (
        <motion.div
          key={task.id}
          initial={{ opacity: 0, height: 0 }}
          animate={{ opacity: 1, height: 'auto' }}
          exit={{ opacity: 0, height: 0 }}
          transition={{ duration: 0.3 }}
          layout
        >
          <motion.div
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            onClick={() => toggleTask(task.id)}
            style={{
              textDecoration: task.completed ? 'line-through' : 'none',
            }}
          >
            {task.title}
          </motion.div>
        </motion.div>
      ))}
    </AnimatePresence>
  );
}

// Animate notifications
function AnimatedNotification() {
  const notifications = useNotificationStore((state) => state.notifications);
  const removeNotification = useNotificationStore((state) => state.removeNotification);

  return (
    <AnimatePresence>
      {notifications.map((notif) => (
        <motion.div
          key={notif.id}
          initial={{ x: 300, opacity: 0 }}
          animate={{ x: 0, opacity: 1 }}
          exit={{ x: 300, opacity: 0 }}
          transition={{ type: 'spring', damping: 20 }}
          className="notification"
          onClick={() => removeNotification(notif.id)}
        >
          {notif.message}
        </motion.div>
      ))}
    </AnimatePresence>
  );
}
```

### Reanimated (React Native)

```tsx
import Animated, { useAnimatedStyle, withSpring } from 'react-native-reanimated';
import { useTaskStore } from '../store/taskStore';

function AnimatedTaskItem({ taskId }: { taskId: string }) {
  const task = useTaskStore((state) => state.tasks[taskId]);
  const toggleTask = useTaskStore((state) => state.toggleTask);

  const animatedStyle = useAnimatedStyle(() => ({
    opacity: withSpring(task.completed ? 0.5 : 1),
    transform: [
      {
        scale: withSpring(task.completed ? 0.95 : 1),
      },
    ],
  }));

  return (
    <Animated.View style={animatedStyle}>
      <TouchableOpacity onPress={() => toggleTask(taskId)}>
        <Text style={{ textDecoration: task.completed ? 'line-through' : 'none' }}>
          {task.title}
        </Text>
      </TouchableOpacity>
    </Animated.View>
  );
}
```

---

## Integration 5: Zustand + Next.js App Router

### Server Component Integration

```tsx
// app/page.tsx (Server Component)
import { TaskListClient } from '@/components/TaskListClient';
import { fetchTasks } from '@/lib/data';

export default async function Page() {
  // Server-side data fetching
  const tasks = await fetchTasks();

  return (
    <div>
      <h1>Task Dashboard</h1>
      <TaskListClient initialTasks={tasks} />
    </div>
  );
}

// components/TaskListClient.tsx (Client Component)
'use client';

import { useEffect } from 'react';
import { useTaskStore } from '@taskflow/shared';

export function TaskListClient({ initialTasks }: { initialTasks: Task[] }) {
  const setTasks = useTaskStore((state) => state.setTasks);
  const tasks = useTaskStore((state) => state.tasks);

  useEffect(() => {
    setTasks(initialTasks);
  }, []);

  return (
    <ul>
      {Object.values(tasks).map((task) => (
        <li key={task.id}>{task.title}</li>
      ))}
    </ul>
  );
}

// lib/data.ts (Server-side data fetching)
import { cache } from 'react';

export const fetchTasks = cache(async () => {
  const res = await fetch('https://api.example.com/tasks');
  return res.json();
});
```

---

## Integration 6: Zustand + React Native / Expo

### Setup with Expo

```bash
npx create-expo-app TaskFlowNative
cd TaskFlowNative
npx expo install zustand @react-native-async-storage/async-storage react-native-mmkv
```

### Mobile Store with AsyncStorage

```typescript
// store/mobileStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { MMKV } from 'react-native-mmkv';

// Option 1: AsyncStorage (easier setup)
export const useMobileStore = create(
  persist(
    (set) => ({
      tasks: [],
      addTask: (task) => set((state) => ({ tasks: [...state.tasks, task] })),
    }),
    {
      name: 'task-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);

// Option 2: MMKV (faster, recommended)
const mmkv = new MMKV({
  id: 'task-storage',
});

const mmkvStorage = {
  getItem: (key: string) => {
    const value = mmkv.getString(key);
    return value || null;
  },
  setItem: (key: string, value: string) => {
    mmkv.set(key, value);
  },
  removeItem: (key: string) => {
    mmkv.delete(key);
  },
};

export const useMMKVStore = create(
  persist(
    (set) => ({
      tasks: [],
      addTask: (task) => set((state) => ({ tasks: [...state.tasks, task] })),
    }),
    {
      name: 'task-storage',
      storage: createJSONStorage(() => mmkvStorage),
    }
  )
);
```

### Performance Optimization for Mobile

```tsx
// Use memoization for list items
const MemoizedTaskItem = React.memo(({ taskId }: { taskId: string }) => {
  const task = useMobileStore((state) => state.tasks[taskId]);
  return <Text>{task.title}</Text>;
});

// Virtualized list
import { FlatList } from 'react-native';

function TaskList() {
  const tasks = useMobileStore((state) => state.tasks);
  const taskIds = Object.keys(tasks);

  const renderItem = ({ item: id }) => <MemoizedTaskItem taskId={id} />;

  return (
    <FlatList
      data={taskIds}
      renderItem={renderItem}
      keyExtractor={(id) => id}
      initialNumToRender={10}
      maxToRenderPerBatch={10}
      windowSize={5}
    />
  );
}
```

---

## Integration 7: Zustand + Redux DevTools

### Setup

```typescript
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

const useStore = create(
  devtools(
    (set) => ({
      count: 0,
      increment: () => set((state) => ({ count: state.count + 1 })),
      decrement: () => set((state) => ({ count: state.count - 1 })),
    }),
    {
      name: 'My Store',
      enabled: process.env.NODE_ENV === 'development',
    }
  )
);
```

### Advanced DevTools Configuration

```typescript
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

const useStore = create(
  devtools(
    (set) => ({
      user: null,
      tasks: [],
      // Named actions for better DevTools visibility
      setUser: (user) => set({ user }, false, 'user/set'),
      addTask: (task) => set((state) => ({ tasks: [...state.tasks, task] }), false, 'tasks/add'),
      deleteTask: (id) => set((state) => ({ tasks: state.tasks.filter(t => t.id !== id) }), false, 'tasks/delete'),
    }),
    {
      name: 'TaskFlow',
      anonymousActionType: 'unknown',
      // Optional: connect to external store
      // store: customStore,
    }
  )
);
```

---

## Integration 8: Zustand + Immer

### Setup

```bash
npm install immer
```

```typescript
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

const useStore = create(
  immer((set) => ({
    user: {
      name: 'Alice',
      preferences: { theme: 'dark', language: 'en' },
      notifications: { email: true, push: false },
    },
    tasks: [],
    // Mutable updates with Immer
    updateUser: (updates) =>
      set((state) => {
        Object.assign(state.user, updates);
      }),
    updatePreferences: (preferences) =>
      set((state) => {
        Object.assign(state.user.preferences, preferences);
      }),
    toggleNotification: (type) =>
      set((state) => {
        state.user.notifications[type] = !state.user.notifications[type];
      }),
    addTask: (task) =>
      set((state) => {
        state.tasks.push(task);
      }),
    updateTask: (id, updates) =>
      set((state) => {
        const task = state.tasks.find((t) => t.id === id);
        if (task) Object.assign(task, updates);
      }),
    deleteTask: (id) =>
      set((state) => {
        state.tasks = state.tasks.filter((t) => t.id !== id);
      }),
  }))
);
```

---

## Integration 9: Zustand + Reselect

### Memoized Selectors

```bash
npm install reselect
```

```typescript
import { createSelector } from 'reselect';

// Base selectors
const selectTasks = (state) => state.tasks;
const selectFilter = (state) => state.filter;
const selectSearchQuery = (state) => state.searchQuery;

// Memoized selectors
export const selectFilteredTasks = createSelector(
  [selectTasks, selectFilter, selectSearchQuery],
  (tasks, filter, searchQuery) => {
    let result = tasks;
    if (filter === 'active') {
      result = result.filter(t => !t.completed);
    } else if (filter === 'completed') {
      result = result.filter(t => t.completed);
    }
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase().trim();
      result = result.filter(t => t.title.toLowerCase().includes(query));
    }
    return result;
  }
);

export const selectTaskStats = createSelector(
  [selectTasks],
  (tasks) => ({
    total: tasks.length,
    completed: tasks.filter(t => t.completed).length,
    active: tasks.filter(t => !t.completed).length,
  })
);

// Component usage
function TaskList() {
  const filteredTasks = useTaskStore(selectFilteredTasks);
  const stats = useTaskStore(selectTaskStats);
  // ...
}
```

---

## Integration 10: Zustand + MSW (Mock Service Worker)

### Testing with MSW

```typescript
// src/mocks/handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/tasks', () => {
    return HttpResponse.json([
      { id: '1', title: 'Task 1', completed: false },
      { id: '2', title: 'Task 2', completed: true },
    ]);
  }),

  http.post('/api/tasks', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json({ id: '3', ...body, completed: false }, { status: 201 });
  }),
];

// src/mocks/browser.ts
import { setupWorker } from 'msw/browser';
import { handlers } from './handlers';

export const worker = setupWorker(...handlers);

// src/mocks/server.ts (for Node tests)
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);
```

---

## Ecosystem Comparison

| Library | Purpose | Best With Zustand |
|---------|---------|-------------------|
| **React Query** | Server state | ✅ Always |
| **React Hook Form** | Forms | ✅ Always |
| **React Router** | Routing | ✅ For URL state |
| **Framer Motion** | Animations | ✅ For UI animations |
| **Immer** | Immutability | ✅ For nested state |
| **Reselect** | Memoization | ✅ For expensive selectors |
| **MSW** | Testing | ✅ For API mocking |
| **Sentry** | Error tracking | ✅ For production |
| **React Native** | Mobile | ✅ For native apps |
| **Next.js** | SSR | ✅ For SSR apps |

---

## Quick Reference: Zustand Ecosystem Packages

| Package | Installation | Description |
|---------|--------------|-------------|
| `zustand` | `npm i zustand` | Core Zustand library |
| `zustand/middleware` | Included | Built-in middleware |
| `zustand/vanilla` | Included | Vanilla store (no React) |
| `zustand/react/shallow` | Included | Shallow comparison |
| `immer` | `npm i immer` | Immutable updates |
| `reselect` | `npm i reselect` | Memoized selectors |
| `@tanstack/react-query` | `npm i @tanstack/react-query` | Server state |
| `react-hook-form` | `npm i react-hook-form` | Form management |
| `@hookform/resolvers` | `npm i @hookform/resolvers` | Schema validation |
| `zod` | `npm i zod` | Schema validation |
| `framer-motion` | `npm i framer-motion` | Animations |
| `react-router-dom` | `npm i react-router-dom` | Routing |

---

## Summary

Zustand's small API surface makes it incredibly versatile. It integrates seamlessly with:

- **Server state management** (React Query, SWR)
- **Form management** (React Hook Form)
- **Routing** (React Router, Next.js)
- **Animations** (Framer Motion, Reanimated)
- **Immutability** (Immer)
- **Memoization** (Reselect)
- **Testing** (MSW)
- **Debugging** (Redux DevTools)
- **Mobile** (React Native, Expo)

The key principle: Zustand handles client state, while other libraries handle their specific domains.
