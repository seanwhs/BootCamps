# Part 5 — Zustand in the Modern React Ecosystem

## Section 21: Zustand with Next.js 16

[STARTING: Part 5, Section 21: Zustand with Next.js 16]

Next.js 16 introduces the App Router, Server Components, streaming, and advanced caching. Zustand fits naturally as a client-side state manager, working alongside these features to deliver fast, interactive user experiences. In this section, you'll learn how to integrate Zustand with Next.js 16's cutting‑edge capabilities.

---

## The Target: Production-Ready Next.js 16 State Management

By the end of this section, you'll be able to:
- Set up Zustand in a Next.js 16 App Router project
- Seed Zustand stores from Server Components
- Prevent hydration mismatches with initial state injection
- Implement request-isolated stores for SSR and multi‑tenant safety
- Use `use cache`, Partial Pre‑rendering (PPR), and Server Actions alongside Zustand
- Build interactive client components with optimistic updates
- Handle streaming and progressive rendering

---

## The Concept: Zustand in the Next.js Ecosystem

Think of Zustand as the **client‑side command center** that works with Next.js's hybrid rendering:

```
┌─────────────────────────────────────────────────────────────────┐
│                    NEXT.JS 16 + ZUSTAND                        │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Server Components (RSC)                                │  │
│  │  • Fetch data                                           │  │
│  │  • Seed Zustand stores via props                        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│                         ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Client Components (Zustand)                            │  │
│  │  • Interactive UI                                       │  │
│  │  • Real-time updates                                    │  │
│  │  • State persistence                                    │  │
│  └──────────────────────────────────────────────────────────┘  │
│                         │                                      │
│                         ▼                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Next.js Features                                       │  │
│  │  • App Router                                           │  │
│  │  • Caching (use cache)                                  │  │
│  │  • Partial Pre‑rendering (PPR)                         │  │
│  │  • Server Actions                                       │  │
│  │  • Streaming & Suspense                                 │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

**Key Principles**:
- Zustand runs only on the client (Server Components cannot use hooks).
- Server Components provide initial data to seed Zustand stores.
- Hydration must be handled carefully to avoid mismatches.
- Request isolation is essential for multi‑user scenarios.

---

## The Implementation: Next.js 16 Integration

### Step 1: Setting Up Next.js 16

```bash
# Create a new Next.js 16 project
npx create-next-app@latest nextjs-zustand-app --typescript --tailwind --app

# Navigate and install Zustand
cd nextjs-zustand-app
npm install zustand
```

### Step 2: Create a Zustand Store (Client-Only)

```typescript
// lib/store/taskStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';

export interface Task {
  id: string;
  title: string;
  completed: boolean;
  priority: 'low' | 'medium' | 'high';
  createdAt: Date;
  updatedAt: Date;
}

export interface TaskStore {
  tasks: Record<string, Task>;
  taskIds: string[];
  isLoading: boolean;
  error: string | null;
  filter: 'all' | 'active' | 'completed';
  searchQuery: string;

  setTasks: (tasks: Task[]) => void;
  addTask: (task: Omit<Task, 'id' | 'createdAt' | 'updatedAt'>) => void;
  toggleTask: (id: string) => void;
  deleteTask: (id: string) => void;
  setFilter: (filter: 'all' | 'active' | 'completed') => void;
  setSearchQuery: (query: string) => void;
  clearTasks: () => void;
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
}

export const useTaskStore = create<TaskStore>()(
  persist(
    immer((set, get) => ({
      tasks: {},
      taskIds: [],
      isLoading: false,
      error: null,
      filter: 'all',
      searchQuery: '',

      setTasks: (tasks: Task[]) => {
        const tasksMap: Record<string, Task> = {};
        const ids: string[] = [];
        for (const task of tasks) {
          tasksMap[task.id] = task;
          ids.push(task.id);
        }
        set({ tasks: tasksMap, taskIds: ids });
      },

      addTask: (taskData) => {
        const id = `task-${Date.now()}`;
        const newTask: Task = {
          ...taskData,
          id,
          createdAt: new Date(),
          updatedAt: new Date(),
        };
        set((state) => {
          state.tasks[id] = newTask;
          state.taskIds.push(id);
        });
      },

      toggleTask: (id) => {
        set((state) => {
          const task = state.tasks[id];
          if (task) {
            task.completed = !task.completed;
            task.updatedAt = new Date();
          }
        });
      },

      deleteTask: (id) => {
        set((state) => {
          delete state.tasks[id];
          state.taskIds = state.taskIds.filter(tid => tid !== id);
        });
      },

      setFilter: (filter) => set({ filter }),
      setSearchQuery: (searchQuery) => set({ searchQuery }),
      clearTasks: () => set({ tasks: {}, taskIds: [] }),
      setLoading: (isLoading) => set({ isLoading }),
      setError: (error) => set({ error }),
    })),
    {
      name: 'task-storage',
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        tasks: state.tasks,
        taskIds: state.taskIds,
        filter: state.filter,
        searchQuery: state.searchQuery,
      }),
    }
  )
);

// Selectors (for efficient subscriptions)
export const selectFilteredTaskIds = (state: TaskStore) => {
  const { tasks, taskIds, filter, searchQuery } = state;
  return taskIds.filter(id => {
    const task = tasks[id];
    if (!task) return false;
    if (filter === 'active' && task.completed) return false;
    if (filter === 'completed' && !task.completed) return false;
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase().trim();
      return task.title.toLowerCase().includes(q);
    }
    return true;
  });
};

export const selectTaskStats = (state: TaskStore) => {
  let total = 0, completed = 0, active = 0;
  for (const id of state.taskIds) {
    const task = state.tasks[id];
    if (task) {
      total++;
      if (task.completed) completed++;
      else active++;
    }
  }
  return { total, completed, active };
};
```

### Step 3: Seeding Zustand from a Server Component

Server Components fetch data and pass it to client components:

```tsx
// app/page.tsx (Server Component)
import { TaskListClient } from '@/components/TaskListClient';
import { fetchTasks } from '@/lib/data';

export default async function Page() {
  const tasks = await fetchTasks(); // Server-side fetch

  return (
    <div className="container mx-auto p-4">
      <h1 className="text-3xl font-bold mb-6">Next.js 16 + Zustand</h1>
      <TaskListClient initialTasks={tasks} />
    </div>
  );
}
```

```tsx
// components/TaskListClient.tsx (Client Component)
'use client';

import React, { useEffect } from 'react';
import { useTaskStore, selectFilteredTaskIds, selectTaskStats } from '@/lib/store/taskStore';
import { TaskItem } from './TaskItem';
import { TaskFilters } from './TaskFilters';
import { AddTaskForm } from './AddTaskForm';

interface TaskListClientProps {
  initialTasks: Task[];
}

export function TaskListClient({ initialTasks }: TaskListClientProps) {
  const setTasks = useTaskStore((state) => state.setTasks);
  const isLoading = useTaskStore((state) => state.isLoading);
  const error = useTaskStore((state) => state.error);
  const filteredIds = useTaskStore(selectFilteredTaskIds);
  const stats = useTaskStore(selectTaskStats);

  // Seed the store with server data (only once)
  useEffect(() => {
    setTasks(initialTasks);
  }, []);

  if (error) return <div className="text-red-500">Error: {error}</div>;

  return (
    <div className="space-y-4">
      <div className="flex gap-4 text-sm">
        <span>Total: {stats.total}</span>
        <span>Completed: {stats.completed}</span>
        <span>Active: {stats.active}</span>
      </div>
      <TaskFilters />
      <AddTaskForm />
      {isLoading ? (
        <div>Loading tasks...</div>
      ) : (
        <ul className="space-y-2">
          {filteredIds.map(id => (
            <TaskItem key={id} taskId={id} />
          ))}
        </ul>
      )}
    </div>
  );
}
```

### Step 4: Hydration Guard

Prevent hydration mismatches with a simple hook:

```typescript
// hooks/useHydrated.ts
import { useEffect, useState } from 'react';

export function useHydrated() {
  const [hydrated, setHydrated] = useState(false);
  useEffect(() => setHydrated(true), []);
  return hydrated;
}
```

```tsx
// components/ClientOnly.tsx
'use client';

import React, { ReactNode } from 'react';
import { useHydrated } from '@/hooks/useHydrated';

export function ClientOnly({ children, fallback = null }: { children: ReactNode; fallback?: ReactNode }) {
  const hydrated = useHydrated();
  return hydrated ? <>{children}</> : <>{fallback}</>;
}
```

### Step 5: Request-Isolated Store (Multi-Tenant/SSR)

Create a store factory for each request (e.g., per user session):

```typescript
// lib/store/createTaskStore.ts
import { createStore } from 'zustand/vanilla';
import { Task, TaskStore } from './taskStore';

export function createTaskStore(initialTasks: Task[] = []) {
  return createStore<TaskStore>()((set, get) => ({
    tasks: {},
    taskIds: [],
    isLoading: false,
    error: null,
    filter: 'all',
    searchQuery: '',
    // ... same actions as above, but without persist (or with no-op storage)
    setTasks: (tasks) => {
      const tasksMap: Record<string, Task> = {};
      const ids: string[] = [];
      for (const task of tasks) {
        tasksMap[task.id] = task;
        ids.push(task.id);
      }
      set({ tasks: tasksMap, taskIds: ids });
    },
    addTask: (taskData) => {
      const id = `task-${Date.now()}`;
      set((state) => ({
        tasks: { ...state.tasks, [id]: { ...taskData, id, createdAt: new Date(), updatedAt: new Date() } },
        taskIds: [...state.taskIds, id],
      }));
    },
    toggleTask: (id) => {
      set((state) => {
        const task = state.tasks[id];
        if (task) {
          state.tasks[id] = { ...task, completed: !task.completed, updatedAt: new Date() };
        }
      });
    },
    deleteTask: (id) => {
      set((state) => {
        const { [id]: _, ...remaining } = state.tasks;
        return {
          tasks: remaining,
          taskIds: state.taskIds.filter(tid => tid !== id),
        };
      });
    },
    setFilter: (filter) => set({ filter }),
    setSearchQuery: (query) => set({ searchQuery: query }),
    clearTasks: () => set({ tasks: {}, taskIds: [] }),
    setLoading: (loading) => set({ isLoading: loading }),
    setError: (error) => set({ error }),
  }));
}
```

Then use `useStore` from `zustand` to consume it in a client component:

```tsx
// components/RequestIsolatedList.tsx
'use client';

import React, { useRef } from 'react';
import { useStore } from 'zustand';
import { createTaskStore } from '@/lib/store/createTaskStore';

export function RequestIsolatedList({ initialTasks }: { initialTasks: Task[] }) {
  const storeRef = useRef<ReturnType<typeof createTaskStore>>();
  if (!storeRef.current) {
    storeRef.current = createTaskStore(initialTasks);
  }
  const tasks = useStore(storeRef.current, (state) => state.tasks);
  const taskIds = useStore(storeRef.current, (state) => state.taskIds);
  const addTask = useStore(storeRef.current, (state) => state.addTask);

  return (
    <div>
      <button onClick={() => addTask({ title: 'New Task', completed: false, priority: 'medium' })}>
        Add
      </button>
      <ul>
        {taskIds.map(id => <li key={id}>{tasks[id].title}</li>)}
      </ul>
    </div>
  );
}
```

### Step 6: Using `use cache` with Zustand

Next.js 16's `use cache` caches data fetching across requests. Combine it with Zustand for efficient data loading:

```typescript
// lib/data.ts
import { cache } from 'react';

export const fetchTasks = cache(async () => {
  console.log('Fetching tasks (cached)...');
  const res = await fetch('https://api.example.com/tasks');
  return res.json();
});
```

### Step 7: Partial Pre‑rendering (PPR) with Zustand

PPR allows static parts to be pre‑rendered while dynamic parts stream. Zustand works naturally with client‑side interactivity:

```tsx
// app/dashboard/page.tsx
import { Suspense } from 'react';
import { TaskListClient } from '@/components/TaskListClient';
import { fetchTasks } from '@/lib/data';

export default function DashboardPage() {
  return (
    <div>
      <h1>Dashboard</h1>
      {/* Static part – pre‑rendered */}
      <div className="bg-gray-100 p-4 mb-4">Welcome back!</div>
      {/* Dynamic part – streamed */}
      <Suspense fallback={<div>Loading tasks...</div>}>
        <AsyncTaskList />
      </Suspense>
    </div>
  );
}

async function AsyncTaskList() {
  const tasks = await fetchTasks();
  return <TaskListClient initialTasks={tasks} />;
}
```

### Step 8: Server Actions with Optimistic Updates

Server Actions mutate data on the server. Combine them with Zustand for optimistic UI:

```tsx
// app/actions/taskActions.ts
'use server';

import { revalidatePath } from 'next/cache';

export async function createTask(formData: FormData) {
  const title = formData.get('title') as string;
  // Save to database...
  await fetch('https://api.example.com/tasks', {
    method: 'POST',
    body: JSON.stringify({ title }),
  });
  revalidatePath('/');
  return { success: true };
}
```

```tsx
// components/AddTaskWithAction.tsx
'use client';

import React, { useState } from 'react';
import { useTaskStore } from '@/lib/store/taskStore';
import { createTask } from '@/app/actions/taskActions';

export function AddTaskWithAction() {
  const [isPending, setIsPending] = useState(false);
  const addTask = useTaskStore((state) => state.addTask);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
    const title = formData.get('title') as string;

    // Optimistic update
    addTask({ title, completed: false, priority: 'medium' });

    setIsPending(true);
    try {
      await createTask(formData);
    } finally {
      setIsPending(false);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input type="text" name="title" placeholder="Task title" />
      <button type="submit" disabled={isPending}>
        {isPending ? 'Adding...' : 'Add Task'}
      </button>
    </form>
  );
}
```

---

## The Verification: Testing Next.js Integration

### Step 1: Run Development Server

```bash
npm run dev
```

Open `http://localhost:3000`:
- ✅ Tasks load from server
- ✅ Interactions update Zustand store
- ✅ Persistence works across page reloads

### Step 2: Hydration Check

Open browser console – no hydration warnings should appear.

### Step 3: Test Server Actions

Add a task – it should appear instantly (optimistic) and persist after reload.

### Step 4: Test Streaming

Navigate to `/dashboard` – skeleton loads first, then tasks stream in.

### Step 5: Test PPR (if enabled)

Enable PPR in `next.config.js`:
```js
module.exports = {
  experimental: { ppr: true },
};
```
Static parts render instantly; dynamic parts stream.

---

## Deep Dive: Request Isolation & Caching

### Multi-User Safety

In a multi-tenant app, each user should have their own store instance. The factory pattern (Step 5) ensures each request gets a fresh store.

### Caching Strategy

| Cache Layer | Purpose | Interaction with Zustand |
|-------------|---------|--------------------------|
| `use cache` | Cache server data across requests | Zustand receives cached data as initial state |
| Client persist | Persist user-specific state across sessions | Zustand's `persist` middleware |
| API cache (HTTP) | Reduce network calls | Zustand can seed from cached API responses |

---

## Common Pitfalls & Solutions

### Pitfall 1: Using Zustand in Server Components

```typescript
// ❌ BAD
export default async function Page() {
  const tasks = useTaskStore.getState().tasks; // ❌ Fails on server
}

// ✅ GOOD
export default async function Page() {
  const tasks = await fetchTasks();
  return <ClientComponent initialTasks={tasks} />;
}
```

### Pitfall 2: Hydration Mismatch

```tsx
// ❌ BAD: Direct use without guard
function MyComponent() {
  const tasks = useTaskStore((state) => state.tasks);
  return <div>{tasks.length}</div>;
}

// ✅ GOOD: With hydration guard
function MyComponent() {
  const hydrated = useHydrated();
  const tasks = useTaskStore((state) => state.tasks);
  if (!hydrated) return <div>Loading...</div>;
  return <div>{tasks.length}</div>;
}
```

### Pitfall 3: Not Using Partialize for Persist

```typescript
// ❌ BAD: Persisting everything, including transient state
persist((set) => ({ /* ... */ }), { name: 'store' });

// ✅ GOOD: Persist only what's needed
persist((set) => ({ /* ... */ }), {
  name: 'store',
  partialize: (state) => ({ tasks: state.tasks, filter: state.filter }),
});
```

---

## Next.js 16 Checklist

- [ ] Zustand store created with `persist` (client-only)
- [ ] Server Components seed stores via props
- [ ] Hydration guard used where needed
- [ ] `use cache` for efficient data fetching
- [ ] Server Actions integrated with optimistic updates
- [ ] Streaming & Suspense work with Zustand
- [ ] PPR supported
- [ ] Request-isolated stores for multi-tenant apps
- [ ] Revalidation triggers Zustand updates
- [ ] No hydration warnings in console

---

## Key Takeaways

1. **Zustand is client-only** – Server Components provide initial data via props.
2. **Hydration guards** prevent mismatches.
3. **Server Actions** + optimistic updates = great UX.
4. **`use cache`** caches server data; Zustand receives it as initial state.
5. **PPR** works with Zustand on the client.
6. **Streaming** with Suspense is seamless.
7. **Request isolation** ensures each user gets a fresh store.
8. **Persistence** should be partialized to avoid storing transient state.
9. **Revalidation** triggers Zustand updates.
10. **Test** hydration, streaming, and server actions thoroughly.
