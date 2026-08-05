# Appendix C: Zustand Troubleshooting & Debugging Guide

This appendix provides a comprehensive troubleshooting guide for common Zustand issues. Each entry includes the problem description, root cause, step-by-step solution, and code examples. Use this as a reference when debugging Zustand applications in development or production.

---

## Quick Issue Index

| Issue | Symptom | Section |
|-------|---------|---------|
| **Rendering Problems** | Component not updating, or updating too much | 1-4 |
| **State Problems** | State not persisting, corrupt state, or desync | 5-8 |
| **Async Problems** | Race conditions, stale data, memory leaks | 9-12 |
| **TypeScript Problems** | Type errors, inference failures | 13-15 |
| **Middleware Problems** | Middleware not working, ordering issues | 16-18 |
| **Production Problems** | Memory leaks, performance, errors | 19-22 |

---

## 1. Component Not Updating When Store Changes

### Problem
Your component doesn't re-render when the store state changes, even though you're using `useStore`.

### Root Cause
- You're mutating state directly instead of creating new objects/arrays
- You're subscribing to the wrong piece of state
- The component is memoized with `React.memo` and props haven't changed

### Solution

```typescript
// ❌ Problem: Direct mutation
const useBadStore = create((set, get) => ({
  tasks: [],
  addTask: (task) => {
    const state = get();
    state.tasks.push(task); // Mutation!
    set(state); // Zustand doesn't detect mutation
  },
}));

// ✅ Solution: Immutable update
const useGoodStore = create((set) => ({
  tasks: [],
  addTask: (task) => {
    set((state) => ({
      tasks: [...state.tasks, task], // New array
    }));
  },
}));

// ✅ Solution: Use Immer
const useImmerStore = create(
  immer((set) => ({
    tasks: [],
    addTask: (task) => {
      set((state) => {
        state.tasks.push(task); // Immer handles immutability
      });
    },
  }))
);

// ❌ Problem: Wrong subscription
function BadComponent() {
  const store = useTaskStore(); // Subscribes to EVERYTHING
  // But component might only need tasks.length
}

// ✅ Solution: Correct subscription
function GoodComponent() {
  const count = useTaskStore((state) => state.taskIds.length);
  // Only updates when taskIds.length changes
}

// ❌ Problem: Memoized component with stale props
const MemoizedComponent = React.memo(({ taskId }) => {
  const task = useTaskStore((state) => state.tasks[taskId]);
  // If taskId doesn't change, component won't re-render even if task changes
});

// ✅ Solution: Ensure component updates when needed
const MemoizedComponent = React.memo(({ taskId }) => {
  const task = useTaskStore((state) => state.tasks[taskId]);
  // The hook itself will cause re-render when task changes
  // React.memo only checks props, not hook results
});
```

---

## 2. Component Re-renders Too Frequently

### Problem
Your component re-renders on every state change, even when the data it displays hasn't changed.

### Root Cause
- Subscribing to the entire store
- Creating new objects in selectors
- Not using `useShallow` for object selectors
- Using inline functions in selectors

### Solution

```typescript
// ❌ Problem: Subscribing to entire store
function BadComponent() {
  const store = useTaskStore(); // Re-renders on ANY change
  return <div>{store.tasks.length}</div>;
}

// ✅ Solution: Subscribe only to what's needed
function GoodComponent() {
  const count = useTaskStore((state) => state.taskIds.length);
  return <div>{count}</div>;
}

// ❌ Problem: New object in selector
function BadComponent() {
  const { tasks, loading } = useTaskStore((state) => ({
    tasks: state.tasks,
    loading: state.loading,
  }));
  // New object every render → re-render every time
  return <div>{tasks.length}</div>;
}

// ✅ Solution: Use useShallow
import { useShallow } from 'zustand/react/shallow';

function GoodComponent() {
  const { tasks, loading } = useTaskStore(
    useShallow((state) => ({
      tasks: state.tasks,
      loading: state.loading,
    }))
  );
  // Only re-renders when tasks or loading actually change
  return <div>{tasks.length}</div>;
}

// ✅ Alternative: Separate subscriptions
function GoodComponent() {
  const tasks = useTaskStore((state) => state.tasks);
  const loading = useTaskStore((state) => state.loading);
  // Each subscription is independent
  return <div>{tasks.length}</div>;
}

// ❌ Problem: Inline selector function (recreated each render)
function BadComponent() {
  const activeTasks = useTaskStore((state) => 
    state.tasks.filter(t => !t.completed)
  );
  // Filter function recreated each render
  return <div>{activeTasks.length}</div>;
}

// ✅ Solution: Extract selector
const selectActiveTasks = (state) => state.tasks.filter(t => !t.completed);

function GoodComponent() {
  const activeTasks = useTaskStore(selectActiveTasks);
  // Selector is stable
  return <div>{activeTasks.length}</div>;
}

// ✅ Solution: Memoize with reselect
import { createSelector } from 'reselect';

const selectActiveTasks = createSelector(
  [(state) => state.tasks],
  (tasks) => tasks.filter(t => !t.completed)
);
```

---

## 3. Hydration Mismatch in Next.js

### Problem
You see hydration errors in your Next.js application when using Zustand with Server Components.

### Root Cause
- Zustand store accessed on server (where localStorage is undefined)
- Server and client render different initial state
- Persist middleware runs on client only

### Solution

```typescript
// ✅ Solution: Hydration guard hook
import { useState, useEffect } from 'react';

export function useHydrated() {
  const [hydrated, setHydrated] = useState(false);
  useEffect(() => setHydrated(true), []);
  return hydrated;
}

// ✅ Solution: Use with Zustand
function ClientComponent() {
  const isHydrated = useHydrated();
  const tasks = useTaskStore((state) => state.tasks);
  
  if (!isHydrated) {
    return <div>Loading...</div>; // Server and initial client render
  }
  
  return <div>{tasks.length}</div>; // Client-only after hydration
}

// ✅ Solution: Seed Zustand from server props
// app/page.tsx (Server Component)
import { fetchTasks } from './lib/data';
import ClientComponent from './ClientComponent';

export default async function Page() {
  const tasks = await fetchTasks();
  return <ClientComponent initialTasks={tasks} />;
}

// app/ClientComponent.tsx
'use client';

import { useEffect } from 'react';
import { useTaskStore } from '@taskflow/shared';

export default function ClientComponent({ initialTasks }) {
  const setTasks = useTaskStore((state) => state.setTasks);
  
  useEffect(() => {
    setTasks(initialTasks);
  }, []); // Only runs once on client
  
  const tasks = useTaskStore((state) => state.tasks);
  return <div>{tasks.length}</div>;
}

// ✅ Solution: No-op storage in server environment
import { createJSONStorage } from 'zustand/middleware';

const isServer = typeof window === 'undefined';

const useStore = create(
  persist(
    (set) => ({ /* ... */ }),
    {
      name: 'storage',
      storage: isServer
        ? {
            getItem: () => null,
            setItem: () => {},
            removeItem: () => {},
          }
        : createJSONStorage(() => localStorage),
    }
  )
);
```

---

## 4. State Not Persisting

### Problem
State is not saved to localStorage or is not restored on page reload.

### Root Cause
- No `persist` middleware
- Incorrect storage key
- Non-serializable data in state
- Storage full or blocked

### Solution

```typescript
// ✅ Solution: Add persist middleware
import { persist, createJSONStorage } from 'zustand/middleware';

const useStore = create(
  persist(
    (set) => ({
      user: null,
      theme: 'light',
      setTheme: (theme) => set({ theme }),
    }),
    {
      name: 'app-storage', // Must be unique
      storage: createJSONStorage(() => localStorage),
    }
  )
);

// ✅ Solution: Check storage availability
export function isStorageAvailable(): boolean {
  try {
    localStorage.setItem('test', 'test');
    localStorage.removeItem('test');
    return true;
  } catch {
    return false;
  }
}

// ✅ Solution: Handle non-serializable data
const useStore = create(
  persist(
    (set) => ({
      tasks: [],
      addTask: (task) => set((state) => ({
        tasks: [...state.tasks, {
          ...task,
          // Convert Dates to strings for serialization
          createdAt: task.createdAt instanceof Date
            ? task.createdAt.toISOString()
            : new Date().toISOString(),
        }],
      })),
    }),
    {
      name: 'task-storage',
      deserialize: (str) => {
        const state = JSON.parse(str);
        // Convert date strings back to Date objects
        if (state.tasks) {
          state.tasks = state.tasks.map(t => ({
            ...t,
            createdAt: new Date(t.createdAt),
          }));
        }
        return state;
      },
    }
  )
);

// ✅ Solution: Partialize to reduce storage size
const useStore = create(
  persist(
    (set) => ({
      user: null,
      theme: 'light',
      isLoading: false, // Not persisted
      error: null, // Not persisted
    }),
    {
      name: 'app-storage',
      partialize: (state) => ({
        user: state.user,
        theme: state.theme,
        // isLoading and error are NOT persisted
      }),
    }
  )
);
```

---

## 5. Corrupted Persisted State

### Problem
After changing your store's shape, existing users have corrupted or broken data.

### Root Cause
- Schema changed without versioning
- No migration strategy
- Users have old data in localStorage

### Solution

```typescript
// ✅ Solution: Version and migrate
const useStore = create(
  persist(
    (set) => ({
      tasks: [],
      taskIds: [],
      // Current schema: tasks as object, taskIds as array
    }),
    {
      name: 'task-storage',
      version: 1, // Current version
      migrate: (persistedState, version) => {
        // Version 0 → Version 1
        if (version === 0) {
          // Old schema had `taskList` array
          const oldState = persistedState as { taskList: Task[] };
          const tasks: Record<string, Task> = {};
          const taskIds: string[] = [];
          for (const task of oldState.taskList) {
            tasks[task.id] = task;
            taskIds.push(task.id);
          }
          return { tasks, taskIds };
        }
        return persistedState;
      },
    }
  )
);

// ✅ Solution: Handle migration errors gracefully
const useStore = create(
  persist(
    (set) => ({ /* ... */ }),
    {
      name: 'task-storage',
      version: 2,
      migrate: (persistedState, version) => {
        try {
          if (version === 0) { /* ... */ }
          return persistedState;
        } catch (error) {
          console.error('Migration failed:', error);
          // Return default state
          return { tasks: {}, taskIds: [] };
        }
      },
      onRehydrateStorage: () => (state, error) => {
        if (error) {
          console.error('Hydration failed:', error);
          // Could reset to default state
          useStore.setState({ tasks: {}, taskIds: [] });
        }
      },
    }
  )
);
```

---

## 6. Race Conditions in Async Actions

### Problem
Async actions complete in the wrong order, causing stale data to overwrite fresh data.

### Root Cause
- No request ID tracking
- No cancellation of stale requests
- User interactions happen faster than API responses

### Solution

```typescript
// ✅ Solution: Track request IDs
const useStore = create((set, get) => ({
  user: null,
  requestId: null,
  fetchUser: async (id) => {
    const requestId = `req-${Date.now()}`;
    set({ requestId, loading: true });
    
    try {
      const user = await api.getUser(id);
      // Only update if this is the latest request
      set((state) => {
        if (state.requestId !== requestId) return state;
        return { user, loading: false };
      });
    } catch (error) {
      set((state) => {
        if (state.requestId !== requestId) return state;
        return { error: error.message, loading: false };
      });
    }
  },
}));

// ✅ Solution: Use AbortController
const useStore = create((set, get) => ({
  data: null,
  controller: null,
  fetchData: async (query) => {
    // Cancel previous request
    const prevController = get().controller;
    if (prevController) {
      prevController.abort();
    }
    
    const controller = new AbortController();
    set({ controller, loading: true });
    
    try {
      const response = await fetch(`/api/search?q=${query}`, {
        signal: controller.signal,
      });
      const data = await response.json();
      set({ data, loading: false, controller: null });
    } catch (error) {
      if (error.name === 'AbortError') {
        console.log('Request cancelled');
      } else {
        set({ error: error.message, loading: false });
      }
      set({ controller: null });
    }
  },
}));

// ✅ Solution: Use debouncing for user input
import { debounce } from 'lodash';

function SearchComponent() {
  const [query, setQuery] = useState('');
  const debouncedSearch = useCallback(
    debounce((q) => {
      useStore.getState().fetchData(q);
    }, 300),
    []
  );
  
  const handleChange = (e) => {
    const value = e.target.value;
    setQuery(value);
    debouncedSearch(value);
  };
}
```

---

## 7. Memory Leaks with Subscriptions

### Problem
Memory usage grows over time, especially after navigating between pages or re-mounting components.

### Root Cause
- Subscriptions not cleaned up in `useEffect`
- Global subscriptions never unsubscribed
- Multiple subscriptions accumulating

### Solution

```typescript
// ✅ Solution: Clean up subscriptions in useEffect
function Component() {
  useEffect(() => {
    const unsubscribe = useStore.subscribe((state) => {
      console.log('State changed:', state);
    });
    
    return () => {
      unsubscribe(); // ✅ Clean up!
    };
  }, []);
  
  return <div>Component</div>;
}

// ✅ Solution: Subscription manager for complex scenarios
class SubscriptionManager {
  private subscriptions: (() => void)[] = [];
  
  add(unsubscribe: () => void) {
    this.subscriptions.push(unsubscribe);
    return unsubscribe;
  }
  
  cleanup() {
    for (const unsub of this.subscriptions) {
      unsub();
    }
    this.subscriptions = [];
  }
}

// Usage
const manager = new SubscriptionManager();
manager.add(useStore.subscribe(handler1));
manager.add(useStore.subscribe(handler2));
// Later...
manager.cleanup();

// ✅ Solution: Auto-cleanup with useEffect helper
function useStoreSubscription<T>(
  store: StoreApi<T>,
  selector: (state: T) => any,
  callback: (value: any) => void
) {
  useEffect(() => {
    const unsubscribe = store.subscribe(
      selector,
      callback
    );
    return unsubscribe;
  }, [store, selector, callback]);
}

// ✅ Solution: Track subscriptions in store
const useStore = create((set, get) => ({
  subscriptions: new Set<() => void>(),
  registerSubscription: (unsub: () => void) => {
    get().subscriptions.add(unsub);
    return () => {
      unsub();
      get().subscriptions.delete(unsub);
    };
  },
  cleanup: () => {
    for (const unsub of get().subscriptions) {
      unsub();
    }
    get().subscriptions.clear();
  },
}));
```

---

## 8. TypeScript Type Errors

### Problem
TypeScript errors when using Zustand, especially with middleware.

### Root Cause
- Incorrect type definitions
- Missing generic parameters
- Middleware type inference issues

### Solution

```typescript
// ✅ Solution: Proper store type
interface Store {
  count: number;
  increment: () => void;
}

const useStore = create<Store>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
}));

// ✅ Solution: Type inference with create()()
const useStore = create<Store>()(
  persist(
    (set) => ({
      count: 0,
      increment: () => set((state) => ({ count: state.count + 1 })),
    }),
    { name: 'storage' }
  )
);

// ✅ Solution: Extract action types
type StoreActions = Pick<Store, 'increment' | 'decrement'>;

// ✅ Solution: Slice types with inference
interface CounterSlice {
  count: number;
  increment: () => void;
}

interface UserSlice {
  user: User | null;
  setUser: (user: User) => void;
}

type Store = CounterSlice & UserSlice;

// ✅ Solution: Generic store factory
function createStore<T>(
  initialState: T,
  actions: (set: any, get: any) => Partial<T>
) {
  return create<T>((set, get) => ({
    ...initialState,
    ...actions(set, get),
  }));
}

// Usage
const useStore = createStore(
  { count: 0 },
  (set) => ({
    increment: () => set((state) => ({ count: state.count + 1 })),
  })
);

// ✅ Solution: Use type assertion when needed (avoid when possible)
const useStore = create(
  persist(
    (set) => ({
      count: 0,
      increment: () => set((state) => ({ count: state.count + 1 })),
    }),
    { name: 'storage' }
  )
) as unknown as typeof useStore; // Only as last resort
```

---

## 9. Middleware Not Working

### Problem
Middleware doesn't work as expected (persist not saving, devtools not showing, etc.).

### Root Cause
- Middleware order is incorrect
- Middleware not properly imported
- Middleware disabled in production

### Solution

```typescript
// ✅ Solution: Correct middleware order
import { create } from 'zustand';
import { devtools, persist, subscribeWithSelector } from 'zustand/middleware';

// Correct order: devtools wraps persist
const useStore = create(
  devtools(                      // <-- Outer: debugging
    persist(                     // <-- Middle: persistence
      subscribeWithSelector(     // <-- Inner: subscription
        (set) => ({
          count: 0,
          increment: () => set((state) => ({ count: state.count + 1 })),
        })
      ),
      { name: 'app-storage' }
    ),
    { name: 'App Store' }
  )
);

// ✅ Solution: Enable devtools in development only
const useStore = create(
  devtools(
    (set) => ({ /* ... */ }),
    {
      enabled: process.env.NODE_ENV === 'development',
      name: 'My Store',
    }
  )
);

// ✅ Solution: Check persist configuration
const useStore = create(
  persist(
    (set) => ({ /* ... */ }),
    {
      name: 'my-storage',
      // storage: createJSONStorage(() => localStorage), // Required
    }
  )
);

// ✅ Solution: Debug middleware
import { StateCreator } from 'zustand';

const withDebug = <T extends object>(
  config: StateCreator<T, [], []>
): StateCreator<T, [], []> => {
  return (set, get, store) => {
    console.log('🔧 Store created');
    return config(
      (args) => {
        console.log('🔄 Before:', get());
        set(args);
        console.log('🔄 After:', get());
      },
      get,
      store
    );
  };
};

const useStore = create(
  withDebug(
    (set) => ({
      count: 0,
      increment: () => set((state) => ({ count: state.count + 1 })),
    })
  )
);
```

---

## 10. Performance Issues with Large State

### Problem
State updates are slow, or the app lags when many components use the store.

### Root Cause
- Large state size (over 500KB)
- Too many subscribers
- Expensive computations in selectors
- No virtualization for large lists

### Solution

```typescript
// ✅ Solution: Normalize state (avoid nested arrays)
// ❌ Bad: Nested arrays
interface BadState {
  tasks: Task[]; // Replaces entire array on every update
}

// ✅ Good: Normalized state
interface GoodState {
  tasks: Record<string, Task>; // O(1) updates
  taskIds: string[]; // Only update when adding/removing
}

// ✅ Solution: Split stores by frequency
// Hot store: frequently updated state
const useHotStore = create((set) => ({
  cursor: { x: 0, y: 0 },
  setCursor: (cursor) => set({ cursor }),
}));

// Cold store: infrequently updated state
const useColdStore = create((set) => ({
  user: null,
  setUser: (user) => set({ user }),
}));

// ✅ Solution: Use selectors with `reselect`
import { createSelector } from 'reselect';

const selectTasks = (state) => state.tasks;
const selectFilter = (state) => state.filter;

const selectFilteredTasks = createSelector(
  [selectTasks, selectFilter],
  (tasks, filter) => {
    // Only recomputes when tasks or filter change
    return tasks.filter(task => task.status === filter);
  }
);

// ✅ Solution: Virtualize large lists
import { FixedSizeList as List } from 'react-window';

function TaskList() {
  const tasks = useTaskStore(selectFilteredTasks);
  const Row = ({ index, style }) => (
    <div style={style}>
      <TaskItem task={tasks[index]} />
    </div>
  );
  
  return (
    <List
      height={500}
      itemCount={tasks.length}
      itemSize={80}
      width="100%"
    >
      {Row}
    </List>
  );
}

// ✅ Solution: Throttle high-frequency updates
import { throttle } from 'lodash';

const useStore = create((set) => ({
  position: { x: 0, y: 0 },
  updatePosition: throttle((x, y) => {
    set({ position: { x, y } });
  }, 16), // ~60fps
}));
```

---

## 11. Validation Errors

### Problem
State updates cause validation errors or invalid state.

### Root Cause
- No validation in store
- Invalid data from API
- User input not validated

### Solution

```typescript
// ✅ Solution: Add validation to actions
const useStore = create((set) => ({
  user: null,
  setUser: (user) => {
    // ✅ Validate before updating
    if (!user.email || !user.name) {
      set({ error: 'User must have email and name' });
      return;
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(user.email)) {
      set({ error: 'Invalid email format' });
      return;
    }
    set({ user, error: null });
  },
}));

// ✅ Solution: Validation middleware
const withValidation = <T extends object>(
  config: StateCreator<T, [], []>,
  schema: z.ZodSchema<T>
): StateCreator<T, [], []> => {
  return (set, get, store) => {
    return config(
      (args) => {
        const nextState = typeof args === 'function'
          ? args(get())
          : args;
        
        // Validate the next state
        try {
          const validated = schema.parse(nextState);
          set(validated);
        } catch (error) {
          console.error('Validation failed:', error);
          // Optionally set error state
          if (error instanceof z.ZodError) {
            set({ validationErrors: error.errors });
          }
          throw error;
        }
      },
      get,
      store
    );
  };
};

// Usage with Zod
import { z } from 'zod';

const userSchema = z.object({
  id: z.string(),
  email: z.string().email(),
  name: z.string().min(1),
  age: z.number().min(0).max(150),
});

const useStore = create(
  withValidation(
    (set) => ({
      user: null,
      setUser: (user) => set({ user }),
    }),
    userSchema
  )
);
```

---

## 12. Cross-Tab State Sync

### Problem
State changes in one tab are not reflected in other open tabs.

### Root Cause
- No broadcast channel or storage event listener
- Multiple instances of the store not synced

### Solution

```typescript
// ✅ Solution: BroadcastChannel for cross-tab sync
const broadcastChannel = new BroadcastChannel('zustand-sync');

const useStore = create((set) => ({
  count: 0,
  increment: () => {
    const newCount = get().count + 1;
    set({ count: newCount });
    broadcastChannel.postMessage({ type: 'update', count: newCount });
  },
}));

// Listen for messages from other tabs
if (typeof window !== 'undefined') {
  broadcastChannel.onmessage = (event) => {
    const { type, count } = event.data;
    if (type === 'update') {
      useStore.setState({ count });
    }
  };
}

// ✅ Solution: Storage event for localStorage persistence
if (typeof window !== 'undefined') {
  window.addEventListener('storage', (event) => {
    if (event.key === 'app-storage' && event.newValue) {
      const state = JSON.parse(event.newValue);
      useStore.setState(state);
    }
  });
}

// ✅ Solution: SharedWorker for complex apps
// shared-worker.js
let state = { count: 0 };
const ports: MessagePort[] = [];

self.onconnect = (event) => {
  const port = event.ports[0];
  ports.push(port);
  port.onmessage = (msg) => {
    const { type, payload } = msg.data;
    if (type === 'update') {
      state = { ...state, ...payload };
      for (const p of ports) {
        p.postMessage({ type: 'sync', state });
      }
    }
  };
  port.postMessage({ type: 'init', state });
};
```

---

## 13. React Native Specific Issues

### Problem
Zustand not working correctly in React Native apps.

### Root Cause
- AsyncStorage not properly configured
- MMKV/AsyncStorage middleware not working
- Bridge performance issues

### Solution

```typescript
// ✅ Solution: AsyncStorage with persist
import AsyncStorage from '@react-native-async-storage/async-storage';

const useStore = create(
  persist(
    (set) => ({ /* ... */ }),
    {
      name: 'app-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);

// ✅ Solution: MMKV for faster performance (recommended)
import { MMKV } from 'react-native-mmkv';

const mmkv = new MMKV({
  id: 'app-storage',
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

const useStore = create(
  persist(
    (set) => ({ /* ... */ }),
    {
      name: 'app-storage',
      storage: createJSONStorage(() => mmkvStorage),
    }
  )
);

// ✅ Solution: Avoid heavy selectors in animations
// ❌ Bad: Expensive selector in animated component
function AnimatedComponent() {
  const tasks = useTaskStore((state) => 
    state.tasks.filter(t => !t.completed).sort((a, b) => a.priority - b.priority)
  );
  // Recomputes on every frame during animation
}

// ✅ Good: Memoize expensive selectors
const selectActiveTasks = createSelector(
  [(state) => state.tasks],
  (tasks) => tasks.filter(t => !t.completed).sort((a, b) => a.priority - b.priority)
);

function AnimatedComponent() {
  const tasks = useTaskStore(selectActiveTasks);
  // Only recomputes when tasks change
}

// ✅ Solution: Use Reanimated with Zustand
import Animated, { useSharedValue, useAnimatedReaction } from 'react-native-reanimated';

function AnimatedCounter() {
  const count = useStore((state) => state.count);
  const animatedCount = useSharedValue(count);
  
  useAnimatedReaction(
    () => count,
    (next) => {
      animatedCount.value = withSpring(next);
    }
  );
  
  // Use animatedCount.value in animations
}
```

---

## 14. Debugging Strategy

### Step-by-Step Debugging

```typescript
// Step 1: Add logging middleware
const useStore = create(
  (set, get) => {
    console.log('🔧 Store created');
    return {
      count: 0,
      increment: () => {
        console.log('📊 Before increment:', get());
        set((state) => ({ count: state.count + 1 }));
        console.log('📊 After increment:', get());
      },
    };
  }
);

// Step 2: Check state in dev tools
// Redux DevTools extension shows all actions

// Step 3: Add render counters to components
function RenderCounter({ name }) {
  const renderCount = useRef(0);
  renderCount.current++;
  return <span>Renders: {renderCount.current}</span>;
}

// Step 4: Monitor state size
function StateSizeMonitor() {
  const state = useStore((state) => state);
  const size = new Blob([JSON.stringify(state)]).size;
  console.log(`📦 State size: ${(size / 1024).toFixed(1)} KB`);
  return null;
}

// Step 5: Check subscriptions
const listenerCount = useStore._listeners?.size || 0;
console.log(`📡 Subscribers: ${listenerCount}`);

// Step 6: Performance profiling
// Use React DevTools Profiler tab
// Look for components that render too often
```

### Debugging Checklist

| Check | What to Look For | Action |
|-------|------------------|--------|
| **Console** | Errors, warnings | Fix errors, investigate warnings |
| **DevTools** | Actions, state diffs | Verify actions and state changes |
| **Renders** | Too many, too few | Adjust subscriptions |
| **State Size** | > 500KB | Split stores, normalize |
| **Subscriptions** | > 100 | Check for memory leaks |
| **Network** | Too many requests | Add deduplication, caching |
| **Performance** | Slow updates | Memoize, optimize selectors |

---

## 15. Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `Cannot read property 'getState' of undefined` | Store not initialized | Check import/export |
| `Maximum call stack size exceeded` | Circular dependency | Break cycle with event bus |
| `Cannot find name 'create'` | Missing import | `import { create } from 'zustand'` |
| `Type 'xxx' is missing the following properties` | Type error | Fix type definitions |
| `Hydration failed because initial UI doesn't match` | SSR mismatch | Use hydration guard |
| `QuotaExceededError` | localStorage full | Clear storage or use partialize |
| `Invalid state shape` | Schema mismatch | Migrate version |
| `Cannot serialize function` | Non-serializable state | Remove functions from state |
| `Unhandled Rejection` | Async error not caught | Add try/catch |

---

## 16. Performance Checklist

- [ ] Components use selectors, not the whole store
- [ ] `useShallow` used for object selectors
- [ ] Expensive selectors memoized with `reselect`
- [ ] `React.memo` used for list items
- [ ] Large lists virtualized
- [ ] State normalized (not nested arrays)
- [ ] Stores split by domain and frequency
- [ ] Request deduplication for API calls
- [ ] Debouncing for user input
- [ ] Subscriptions cleaned up
- [ ] State size monitored (< 500KB)
- [ ] No inline functions in selectors
- [ ] `useMemo` for derived state in components

---

## 17. Production Checklist

- [ ] `devtools` enabled only in development
- [ ] `persist` configured correctly
- [ ] Error boundary middleware in place
- [ ] Performance monitoring middleware in production
- [ ] Logging disabled in production or sampled
- [ ] Sentry or error tracking integrated
- [ ] Service worker for offline support (if needed)
- [ ] CSP headers configured
- [ ] No sensitive data in logs
- [ ] State size monitored
- [ ] Rollback strategy for persistence migrations

---

## 18. Quick Fix Reference

| Issue | One-Line Fix |
|-------|--------------|
| Component not updating | `set((state) => ({ tasks: [...state.tasks, newTask] }))` |
| Too many re-renders | `const count = useStore((state) => state.count)` |
| State not persisting | Add `persist` middleware |
| Race condition | Track `requestId` |
| Memory leak | `return () => unsubscribe()` |
| SSR hydration | Use `useHydrated()` guard |
| Type errors | `create<Store>()(...)` |
| Slow renders | `const tasks = useStore(selectFilteredTasks)` |

